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
    private final NotificationService notificationService;

    // ================== CÁC PHƯƠNG THỨC CHÍNH (PUBLIC) ==================

    @Transactional
    @com.bizflow.backend.core.annotation.AuditAction(action = "CREATE_ORDER", entityType = "ORDER")
    public OrderDTO createOrder(CreateOrderRequest request) {
        Long storeId = UserContext.getCurrentStoreId();
        String createdBy = UserContext.getCurrentUsername();

        log.info("Creating order for storeId={}, user={}", storeId, createdBy);

        Customer customer = validateCustomerExists(request.getCustomerId(), storeId);
        validateOrderItems(request.getItems());

        List<OrderItemData> itemDataList = checkAndBuildOrderItems(request.getItems(), storeId);

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

    @Transactional
    @com.bizflow.backend.core.annotation.AuditAction(action = "UPDATE_ORDER", entityType = "ORDER")
    public OrderDTO updateOrder(Long orderId, CreateOrderRequest request) {
        Long storeId = UserContext.getCurrentStoreId();
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn hàng: " + orderId));

        if (!order.getStoreId().equals(storeId)) {
            throw new BusinessException(4003, "Bạn không có quyền sửa đơn hàng này");
        }

        rollbackInventory(storeId, orderItemRepository.findByOrderId(orderId), orderId);
        orderItemRepository.deleteByOrderId(orderId);

        Customer customer = validateCustomerExists(request.getCustomerId(), storeId);
        List<OrderItemData> newItemData = checkAndBuildOrderItems(request.getItems(), storeId);

        BigDecimal subtotal = calculateSubtotal(newItemData);
        BigDecimal discountAmount = request.getDiscountAmount() != null ? request.getDiscountAmount() : BigDecimal.ZERO;
        BigDecimal totalAmount = calculateTotal(subtotal, discountAmount);

        updateOrderEntity(order, customer.getId(), subtotal, discountAmount, totalAmount, request);
        Order updatedOrder = orderRepository.save(order);

        persistOrderItems(updatedOrder.getId(), newItemData);
        reduceInventory(storeId, newItemData, updatedOrder.getId());

        return mapToDTO(updatedOrder, orderItemRepository.findByOrderId(updatedOrder.getId()));
    }

    @Transactional
    @com.bizflow.backend.core.annotation.AuditAction(action = "CANCEL_ORDER", entityType = "ORDER")
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

        rollbackInventory(storeId, orderItemRepository.findByOrderId(orderId), orderId);
        order.setStatus(Order.OrderStatus.CANCELLED);
        orderRepository.save(order);
    }

    public Page<OrderDTO> getAllOrders(String status, LocalDate startDate, LocalDate endDate, Long customerId,
            Pageable pageable) {
        Long storeId = UserContext.getCurrentStoreId();
        LocalDateTime start = (startDate != null) ? startDate.atStartOfDay() : null;
        LocalDateTime end = (endDate != null) ? endDate.atTime(23, 59, 59) : null;

        Order.OrderStatus enumStatus = null;
        if (status != null && !"ALL".equalsIgnoreCase(status)) {
            enumStatus = Order.OrderStatus.valueOf(status.toUpperCase());
        }

        return orderRepository.findAllWithFilters(storeId, enumStatus, customerId, start, end, pageable)
                .map(o -> mapToDTO(o, orderItemRepository.findByOrderId(o.getId())));
    }

    public OrderDTO getOrderById(Long id) {
        Long storeId = UserContext.getCurrentStoreId();
        Order order = orderRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Order not found"));
        if (!order.getStoreId().equals(storeId))
            throw new BusinessException(4003, "Access denied");
        return mapToDTO(order, orderItemRepository.findByOrderId(order.getId()));
    }

    // ================== CÁC PHƯƠNG THỨC HỖ TRỢ (PRIVATE) ==================

    private Customer validateCustomerExists(Long customerId, Long storeId) {
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found: " + customerId));
        if (!customer.getStoreId().equals(storeId))
            throw new BusinessException(4003, "Store mismatch");
        return customer;
    }

    private void validateOrderItems(List<CreateOrderRequest.OrderItemRequest> items) {
        if (items == null || items.isEmpty())
            throw new BusinessException(4002, "Order items empty");
    }

    private List<OrderItemData> checkAndBuildOrderItems(List<CreateOrderRequest.OrderItemRequest> itemRequests,
            Long storeId) {
        List<OrderItemData> itemDataList = new ArrayList<>();
        for (CreateOrderRequest.OrderItemRequest req : itemRequests) {
            Product prod = productRepository.findById(req.getProductId())
                    .orElseThrow(() -> new ResourceNotFoundException("Product not found"));

            // Find or create inventory for product
            Inventory inv = inventoryRepository.findByStoreIdAndProductId(storeId, prod.getId())
                    .orElseGet(() -> {
                        // Auto-create inventory if product doesn't track stock OR create with 0
                        // quantity
                        if (!prod.getTrackStock()) {
                            // Product không theo dõi kho -> cho phép bán không giới hạn
                            Inventory newInv = Inventory.builder()
                                    .storeId(storeId)
                                    .productId(prod.getId())
                                    .quantity(999999) // Số lượng lớn để không bị hết
                                    .availableQuantity(999999)
                                    .build();
                            return inventoryRepository.save(newInv);
                        } else {
                            // Product có theo dõi kho nhưng chưa nhập -> tạo với số lượng 0
                            Inventory newInv = Inventory.builder()
                                    .storeId(storeId)
                                    .productId(prod.getId())
                                    .quantity(0)
                                    .availableQuantity(0)
                                    .build();
                            inventoryRepository.save(newInv);
                            throw new BusinessException(4005,
                                    "Sản phẩm '" + prod.getName() + "' hết hàng. Vui lòng nhập kho trước.");
                        }
                    });

            // Check available quantity only if product tracks stock
            if (prod.getTrackStock() && inv.getAvailableQuantity() < req.getQuantity()) {
                throw new BusinessException(4006,
                        "Hết hàng: " + prod.getName() + " (Còn: " + inv.getAvailableQuantity() + ")");
            }

            itemDataList.add(OrderItemData.builder()
                    .product(prod)
                    .quantity(req.getQuantity())
                    .unitPrice(req.getUnitPrice() != null ? req.getUnitPrice() : prod.getPrice())
                    .totalAmount((req.getUnitPrice() != null ? req.getUnitPrice() : prod.getPrice())
                            .multiply(BigDecimal.valueOf(req.getQuantity())))
                    .build());
        }
        return itemDataList;
    }

    private BigDecimal calculateSubtotal(List<OrderItemData> items) {
        return items.stream().map(OrderItemData::getTotalAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal calculateTotal(BigDecimal subtotal, BigDecimal discount) {
        BigDecimal total = subtotal.subtract(discount);
        if (total.compareTo(BigDecimal.ZERO) < 0)
            throw new BusinessException(4007, "Discount too high");
        return total;
    }

    private Order buildOrder(Long storeId, Long customerId, BigDecimal subtotal, BigDecimal total,
            CreateOrderRequest req, String user) {
        return Order.builder()
                .storeId(storeId)
                .orderNumber(generateOrderNumber(storeId))
                .customerId(customerId)
                .employeeId(UserContext.getCurrentUserId())
                .subtotal(subtotal)
                .discountAmount(req.getDiscountAmount() != null ? req.getDiscountAmount() : BigDecimal.ZERO)
                .totalAmount(total)
                .status(Order.OrderStatus.CONFIRMED)
                .paymentType(
                        req.getPaymentType() != null ? Order.PaymentType.valueOf(req.getPaymentType().toUpperCase())
                                : Order.PaymentType.CASH)
                .notes(req.getNotes())
                .createdBy(user)
                .createdAt(LocalDateTime.now())
                .build();
    }

    private void updateOrderEntity(Order order, Long customerId, BigDecimal subtotal, BigDecimal discount,
            BigDecimal total, CreateOrderRequest request) {
        order.setCustomerId(customerId);
        order.setSubtotal(subtotal);
        order.setDiscountAmount(discount);
        order.setTotalAmount(total);
        order.setNotes(request.getNotes());
        if (request.getStatus() != null)
            order.setStatus(Order.OrderStatus.valueOf(request.getStatus().toUpperCase()));
    }

    private void persistOrderItems(Long orderId, List<OrderItemData> items) {
        for (OrderItemData item : items) {
            orderItemRepository.save(OrderItem.builder()
                    .orderId(orderId)
                    .productId(item.getProduct().getId())
                    .quantity(item.getQuantity())
                    .unitPrice(item.getUnitPrice())
                    .totalAmount(item.getTotalAmount())
                    .createdAt(LocalDateTime.now())
                    .build());
        }
    }

    private void reduceInventory(Long storeId, List<OrderItemData> items, Long orderId) {
        for (OrderItemData item : items) {
            Inventory inv = inventoryRepository.findByStoreIdAndProductId(storeId, item.getProduct().getId())
                    .orElseThrow();
            inv.setQuantity(inv.getQuantity() - item.getQuantity());
            inv.setAvailableQuantity(inv.getAvailableQuantity() - item.getQuantity());
            inventoryRepository.save(inv);

            stockMovementRepository.save(StockMovement.builder()
                    .storeId(storeId).productId(item.getProduct().getId()).type(StockMovement.MovementType.SALE)
                    .quantity(-item.getQuantity()).referenceId(orderId).referenceType("ORDER")
                    .createdBy(UserContext.getCurrentUsername()).createdAt(LocalDateTime.now()).build());
        }
    }

    private void rollbackInventory(Long storeId, List<OrderItem> items, Long orderId) {
        for (OrderItem item : items) {
            Inventory inv = inventoryRepository.findByStoreIdAndProductId(storeId, item.getProductId()).orElseThrow();
            inv.setQuantity(inv.getQuantity() + item.getQuantity());
            inv.setAvailableQuantity(inv.getAvailableQuantity() + item.getQuantity());
            inventoryRepository.save(inv);

            stockMovementRepository.save(StockMovement.builder()
                    .storeId(storeId).productId(item.getProductId()).type(StockMovement.MovementType.IN)
                    .quantity(item.getQuantity()).referenceId(orderId).referenceType("ORDER_REVISION")
                    .createdBy(UserContext.getCurrentUsername()).createdAt(LocalDateTime.now()).build());
        }
    }

    private void createDebtRecord(Long storeId, Order order, Customer customer) {
        debtRepository.save(Debt.builder()
                .storeId(storeId).orderId(order.getId()).customerId(customer.getId())
                .originalAmount(order.getTotalAmount()).paidAmount(BigDecimal.ZERO).unpaidAmount(order.getTotalAmount())
                .status(Debt.DebtStatus.UNPAID).dueDate(LocalDateTime.now().plusDays(30).toLocalDate())
                .createdAt(LocalDateTime.now()).build());
    }

    private void sendOrderNotification(Long storeId, Order order, Customer customer, BigDecimal total) {
        try {
            notificationService.sendTopicNotification("store_" + storeId, "Đơn mới: " + order.getOrderNumber(),
                    "Khách: " + customer.getName() + " - " + total, order.getId());
        } catch (Exception e) {
            log.warn("Notify failed");
        }
    }

    private String generateOrderNumber(Long storeId) {
        return "ORD-" + storeId + "-" + System.currentTimeMillis();
    }

    private OrderDTO mapToDTO(Order order, List<OrderItem> items) {
        Customer customer = customerRepository.findById(order.getCustomerId()).orElse(null);

        // Build items with product names
        List<OrderDTO.OrderItemDTO> itemDTOs = items.stream().map(i -> {
            Product product = productRepository.findById(i.getProductId()).orElse(null);
            return OrderDTO.OrderItemDTO.builder()
                    .productId(i.getProductId())
                    .productName(product != null ? product.getName() : "Unknown")
                    .quantity(i.getQuantity())
                    .unitPrice(i.getUnitPrice())
                    .totalAmount(i.getTotalAmount())
                    .build();
        }).toList();

        return OrderDTO.builder()
                .id(order.getId())
                .orderCode(order.getOrderNumber())
                .customerId(order.getCustomerId())
                .customerName(customer != null ? customer.getName() : "Unknown")
                .subtotal(order.getSubtotal())
                .discountAmount(order.getDiscountAmount())
                .totalAmount(order.getTotalAmount())
                .status(order.getStatus().toString())
                .paymentType(order.getPaymentType().toString())
                .createdAt(order.getCreatedAt())
                .items(itemDTOs)
                .build();
    }

    @lombok.Data
    @lombok.Builder
    private static class OrderItemData {
        private Product product;
        private Integer quantity;
        private BigDecimal unitPrice;
        private BigDecimal totalAmount;
    }
}