package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.*;
import com.bizflow.backend.infrastructure.persistence.repository.*;
import com.bizflow.backend.presentation.dto.request.CreateOrderRequest;
import com.bizflow.backend.presentation.dto.response.OrderDTO;
import com.bizflow.backend.core.common.UserContext;
import com.bizflow.backend.presentation.exception.BusinessException;
import com.bizflow.backend.presentation.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final CustomerRepository customerRepository;
    private final ProductRepository productRepository;
    private final InventoryRepository inventoryRepository;
    private final StockMovementRepository stockMovementRepository;
    private final DebtRepository debtRepository;
    private final PaymentRepository paymentRepository;
    private final NotificationService notificationService;

    // ================== CÁC PHƯƠNG THỨC CHÍNH (PUBLIC) ==================

    @Transactional
    public OrderDTO createOrder(CreateOrderRequest request) {
        Long storeId = UserContext.getCurrentStoreId();
        String createdBy = UserContext.getCurrentUsername();

        log.info("Creating order for storeId={}, user={}", storeId, createdBy);

        Customer customer = validateCustomerExists(request.getCustomerId(), storeId);
        List<CreateOrderRequest.OrderItemRequest> itemRequests = validateOrderItems(request.getItems());

        List<OrderItemData> itemDataList = checkAndBuildOrderItems(itemRequests, storeId);

        BigDecimal subtotal = calculateSubtotal(itemDataList);
        BigDecimal discountAmount = request.getDiscountAmount() != null ? request.getDiscountAmount() : BigDecimal.ZERO;
        BigDecimal totalAmount = calculateTotal(subtotal, discountAmount);

        Order order = buildOrder(storeId, customer.getId(), subtotal, totalAmount, request, createdBy);
        Order savedOrder = orderRepository.save(order);

        persistOrderItems(savedOrder.getId(), itemDataList);
        reduceInventory(storeId, itemDataList, savedOrder.getId());

        if (!Order.PaymentType.CASH.toString().equals(request.getPaymentType())) {
            createDebtRecord(storeId, savedOrder, customer);
        }

        sendOrderNotification(storeId, savedOrder, customer, totalAmount);

        return mapToDTO(savedOrder, orderItemRepository.findByOrderId(savedOrder.getId()));
    }

    /**
     * CẬP NHẬT ĐƠN HÀNG (MỚI)
     * Quy trình: Hoàn kho cũ -> Xóa chi tiết cũ -> Tính toán mới -> Trừ kho mới
     */
    @Transactional
    public OrderDTO updateOrder(Long orderId, CreateOrderRequest request) {
        Long storeId = UserContext.getCurrentStoreId();
        String username = UserContext.getCurrentUsername();

        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn hàng: " + orderId));

        if (!order.getStoreId().equals(storeId)) {
            throw new BusinessException(4003, "Bạn không có quyền sửa đơn hàng này");
        }

        log.info("Updating order: {} by user: {}", order.getOrderNumber(), username);

        // 1. Hoàn trả tồn kho cũ (Rollback Inventory)
        List<OrderItem> oldItems = orderItemRepository.findByOrderId(orderId);
        rollbackInventory(storeId, oldItems, orderId);

        // 2. Xóa các mặt hàng cũ trong đơn hàng
        orderItemRepository.deleteByOrderId(orderId);

        // 3. Tính toán dữ liệu mới
        Customer customer = validateCustomerExists(request.getCustomerId(), storeId);
        List<OrderItemData> newItemData = checkAndBuildOrderItems(request.getItems(), storeId);

        BigDecimal subtotal = calculateSubtotal(newItemData);
        BigDecimal discountAmount = request.getDiscountAmount() != null ? request.getDiscountAmount() : BigDecimal.ZERO;
        BigDecimal totalAmount = calculateTotal(subtotal, discountAmount);

        // 4. Cập nhật thông tin Order chính
        updateOrderEntity(order, customer.getId(), subtotal, discountAmount, totalAmount, request);
        Order updatedOrder = orderRepository.save(order);

        // 5. Lưu mặt hàng mới và trừ kho mới
        persistOrderItems(updatedOrder.getId(), newItemData);
        reduceInventory(storeId, newItemData, updatedOrder.getId());

        return mapToDTO(updatedOrder, orderItemRepository.findByOrderId(updatedOrder.getId()));
    }

    /**
     * HỦY/XÓA ĐƠN HÀNG (MỚI)
     * Chuyển trạng thái sang CANCELLED và hoàn kho
     */
    @Transactional
    public void cancelOrder(Long orderId) {
        Long storeId = UserContext.getCurrentStoreId();
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn hàng: " + orderId));

        if (!order.getStoreId().equals(storeId)) {
            throw new BusinessException(4003, "Bạn không có quyền hủy đơn hàng này");
        }

        if (order.getStatus() == Order.OrderStatus.CANCELLED) {
            throw new BusinessException(4008, "Đơn hàng này đã được hủy trước đó");
        }

        // 1. Hoàn trả kho
        List<OrderItem> items = orderItemRepository.findByOrderId(orderId);
        rollbackInventory(storeId, items, orderId);

        // 2. Cập nhật trạng thái
        order.setStatus(Order.OrderStatus.CANCELLED);
        orderRepository.save(order);

        log.info("Order {} cancelled and inventory restored", order.getOrderNumber());
    }

    public Page<OrderDTO> getAllOrders(String status, LocalDate startDate, LocalDate endDate, Long customerId, Pageable pageable) {
        Long storeId = UserContext.getCurrentStoreId();
        LocalDateTime start = (startDate != null) ? startDate.atStartOfDay() : null;
        LocalDateTime end = (endDate != null) ? endDate.atTime(23, 59, 59, 999999999) : null;

        Order.OrderStatus enumStatus = null;
        if (status != null && !status.isEmpty() && !status.equalsIgnoreCase("ALL")) {
            try {
                enumStatus = Order.OrderStatus.valueOf(status.toUpperCase());
            } catch (IllegalArgumentException e) {
                log.error("Invalid status filter: {}", status);
            }
        }

        Page<Order> orders = orderRepository.findAllWithFilters(storeId, enumStatus, customerId, start, end, pageable);
        return orders.map(order -> mapToDTO(order, orderItemRepository.findByOrderId(order.getId())));
    }

    public OrderDTO getOrderById(Long id) {
        Long storeId = UserContext.getCurrentStoreId();
        Order order = orderRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Order not found"));
        if (!order.getStoreId().equals(storeId)) throw new BusinessException(4003, "Access denied");
        return mapToDTO(order, orderItemRepository.findByOrderId(order.getId()));
    }

    // ================== CÁC PHƯƠNG THỨC HỖ TRỢ (PRIVATE) ==================

    private void rollbackInventory(Long storeId, List<OrderItem> items, Long orderId) {
        for (OrderItem item : items) {
            Inventory inv = inventoryRepository.findByStoreIdAndProductId(storeId, item.getProductId()).orElseThrow();
            inv.setQuantity(inv.getQuantity() + item.getQuantity());
            inv.setAvailableQuantity(inv.getAvailableQuantity() + item.getQuantity());
            inventoryRepository.save(inv);

            stockMovementRepository.save(StockMovement.builder()
                    .storeId(storeId).productId(item.getProductId())
                    .type(StockMovement.MovementType.IN) // Nhập lại kho
                    .quantity(item.getQuantity()).referenceId(orderId).referenceType("ORDER_REVISION")
                    .createdBy(UserContext.getCurrentUsername()).createdAt(LocalDateTime.now()).build());
        }
    }

    private void updateOrderEntity(Order order, Long customerId, BigDecimal subtotal, BigDecimal discount, BigDecimal total, CreateOrderRequest request) {
        order.setCustomerId(customerId);
        order.setSubtotal(subtotal);
        order.setDiscountAmount(discount);
        order.setTotalAmount(total);
        order.setNotes(request.getNotes());

        try {
            if (request.getStatus() != null) order.setStatus(Order.OrderStatus.valueOf(request.getStatus().toUpperCase()));
            if (request.getPaymentType() != null) order.setPaymentType(Order.PaymentType.valueOf(request.getPaymentType().toUpperCase()));
        } catch (Exception e) {
            log.warn("Enum parsing failed during update");
        }
    }

    private Customer validateCustomerExists(Long customerId, Long storeId) {
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found: " + customerId));
        if (!customer.getStoreId().equals(storeId)) throw new BusinessException(4003, "Store mismatch");
        return customer;
    }

    private List<CreateOrderRequest.OrderItemRequest> validateOrderItems(List<CreateOrderRequest.OrderItemRequest> items) {
        if (items == null || items.isEmpty()) throw new BusinessException(4002, "Order items empty");
        return items;
    }

    private List<OrderItemData> checkAndBuildOrderItems(List<CreateOrderRequest.OrderItemRequest> itemRequests, Long storeId) {
        List<OrderItemData> itemDataList = new ArrayList<>();
        for (CreateOrderRequest.OrderItemRequest req : itemRequests) {
            Product prod = productRepository.findById(req.getProductId()).orElseThrow(() -> new ResourceNotFoundException("Product not found"));
            Inventory inv = inventoryRepository.findByStoreIdAndProductId(storeId, prod.getId())
                    .orElseThrow(() -> new BusinessException(4005, "No inventory"));

            if (inv.getAvailableQuantity() < req.getQuantity()) {
                throw new BusinessException(4006, "Hết hàng: " + prod.getName());
            }

            itemDataList.add(OrderItemData.builder()
                    .product(prod).quantity(req.getQuantity()).unitPrice(req.getUnitPrice())
                    .totalAmount(req.getUnitPrice().multiply(BigDecimal.valueOf(req.getQuantity()))).build());
        }
        return itemDataList;
    }

    private BigDecimal calculateSubtotal(List<OrderItemData> items) {
        return items.stream().map(OrderItemData::getTotalAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal calculateTotal(BigDecimal subtotal, BigDecimal discount) {
        BigDecimal total = subtotal.subtract(discount);
        if (total.compareTo(BigDecimal.ZERO) < 0) throw new BusinessException(4007, "Discount too high");
        return total;
    }

    private Order buildOrder(Long storeId, Long customerId, BigDecimal subtotal, BigDecimal total, CreateOrderRequest req, String user) {
        return Order.builder()
                .storeId(storeId).orderNumber(generateOrderNumber(storeId)).customerId(customerId)
                .employeeId(UserContext.getCurrentUserId()).subtotal(subtotal).discountAmount(req.getDiscountAmount())
                .totalAmount(total).status(Order.OrderStatus.CONFIRMED).paymentType(Order.PaymentType.CASH)
                .notes(req.getNotes()).createdBy(user).createdAt(LocalDateTime.now()).build();
    }

    private void persistOrderItems(Long orderId, List<OrderItemData> items) {
        for (OrderItemData item : items) {
            orderItemRepository.save(OrderItem.builder()
                    .orderId(orderId).productId(item.getProduct().getId()).quantity(item.getQuantity())
                    .unitPrice(item.getUnitPrice()).totalAmount(item.getTotalAmount()).createdAt(LocalDateTime.now()).build());
        }
    }

    private void reduceInventory(Long storeId, List<OrderItemData> items, Long orderId) {
        for (OrderItemData item : items) {
            Inventory inv = inventoryRepository.findByStoreIdAndProductId(storeId, item.getProduct().getId()).orElseThrow();
            inv.setQuantity(inv.getQuantity() - item.getQuantity());
            inv.setAvailableQuantity(inv.getAvailableQuantity() - item.getQuantity());
            inventoryRepository.save(inv);

            stockMovementRepository.save(StockMovement.builder()
                    .storeId(storeId).productId(item.getProduct().getId()).type(StockMovement.MovementType.SALE)
                    .quantity(-item.getQuantity()).referenceId(orderId).referenceType("ORDER")
                    .createdBy(UserContext.getCurrentUsername()).createdAt(LocalDateTime.now()).build());
        }
    }

    private void createDebtRecord(Long storeId, Order order, Customer customer) {
        debtRepository.save(Debt.builder()
                .storeId(storeId).orderId(order.getId()).customerId(customer.getId())
                .originalAmount(order.getTotalAmount()).paidAmount(BigDecimal.ZERO).unpaidAmount(order.getTotalAmount())
                .status(Debt.DebtStatus.UNPAID).dueDate(LocalDateTime.now().plusDays(30).toLocalDate()).createdAt(LocalDateTime.now()).build());
    }

    private void sendOrderNotification(Long storeId, Order order, Customer customer, BigDecimal total) {
        try {
            notificationService.sendTopicNotification("store_" + storeId, "Đơn mới: " + order.getOrderNumber(), "Khách: " + customer.getName() + " - " + total);
        } catch (Exception e) { log.warn("Notify failed"); }
    }

    private String generateOrderNumber(Long storeId) {
        return String.format("ORD-%d-%s-%04d", storeId, LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd")), System.nanoTime() % 10000);
    }

    private OrderDTO mapToDTO(Order order, List<OrderItem> items) {
        return OrderDTO.builder()
                .id(order.getId()).orderNumber(order.getOrderNumber()).customerId(order.getCustomerId())
                .subtotal(order.getSubtotal()).discountAmount(order.getDiscountAmount()).totalAmount(order.getTotalAmount())
                .paymentType(order.getPaymentType().toString()).status(order.getStatus().toString())
                .createdAt(order.getCreatedAt())
                .items(items.stream().map(i -> OrderDTO.OrderItemDTO.builder().productId(i.getProductId()).quantity(i.getQuantity()).unitPrice(i.getUnitPrice()).totalAmount(i.getTotalAmount()).build()).toList())
                .build();
    }

    @lombok.Data @lombok.Builder
    private static class OrderItemData {
        private Product product;
        private Integer quantity;
        private BigDecimal unitPrice;
        private BigDecimal totalAmount;
    }
}