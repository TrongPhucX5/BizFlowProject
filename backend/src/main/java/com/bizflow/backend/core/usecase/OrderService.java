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

/**
 * OrderService: Example implementation showing architectural best practices
 * 
 * PATTERN 1: Multi-Tenancy (Rủi ro #1 - FIXED)
 * - ALWAYS extract storeId from UserContext (JWT token)
 * - NEVER trust storeId from request parameter
 * - All repository calls include store_id filter
 * 
 * PATTERN 2: Service Layer Structure (Rủi ro #2 - FIXED)
 * - Main public method delegates to private methods
 * - Each private method has single responsibility:
 *   * validateXxx() - Data validation
 *   * buildXxx() - Entity construction
 *   * persistXxx() - Database saving
 *   * calculateXxx() - Business logic calculations
 *   * notifyXxx() - Side effects (notifications, events)
 * 
 * PATTERN 3: Transaction Management
 * - @Transactional ensures atomicity
 * - Multiple DB operations in one transaction
 * 
 * PATTERN 4: Error Handling
 * - Use custom exceptions (BusinessException, ResourceNotFoundException)
 * - Let GlobalExceptionHandler convert to HTTP responses
 * 
 * PATTERN 5: Dependency Injection
 * - Constructor injection (via Lombok @RequiredArgsConstructor)
 * - All dependencies are final and immutable
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {

    // ========== Dependencies (Injected via constructor) ==========
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final CustomerRepository customerRepository;
    private final ProductRepository productRepository;
    private final InventoryRepository inventoryRepository;
    private final StockMovementRepository stockMovementRepository;
    private final DebtRepository debtRepository;
    private final PaymentRepository paymentRepository;
    private final NotificationService notificationService; // Added NotificationService

    // ========== PUBLIC METHODS (Main business operations) ==========

    /**
     * Create new order
     * 
     * Flow:
     * 1. Extract storeId from JWT token (UserContext)
     * 2. Validate customer & products exist in user's store
     * 3. Check inventory (sufficient stock)
     * 4. Calculate order total
     * 5. Create Order entity
     * 6. Create OrderItem entities
     * 7. Reduce inventory
     * 8. Create Debt record
     * 9. Log operation
     * 
     * CRITICAL: Entire operation wrapped in @Transactional
     * If any step fails → entire transaction rolls back
     */
    @Transactional
    public OrderDTO createOrder(CreateOrderRequest request) {
        // 1. Get storeId from JWT token (CANNOT be overridden by client)
        Long storeId = UserContext.getCurrentStoreId();
        String createdBy = UserContext.getCurrentUsername();
        
        log.info("Creating order for storeId={}, user={}", storeId, createdBy);

        // 2. Validate input
        Customer customer = validateCustomerExists(request.getCustomerId(), storeId);
        List<CreateOrderRequest.OrderItemRequest> itemRequests = validateOrderItems(request.getItems());
        
        // 3. Check inventory for all items
        List<OrderItemData> itemDataList = checkAndBuildOrderItems(itemRequests, storeId);
        
        // 4. Calculate totals
        BigDecimal subtotal = calculateSubtotal(itemDataList);
        BigDecimal discountAmount = request.getDiscountAmount() != null ? request.getDiscountAmount() : BigDecimal.ZERO;
        BigDecimal totalAmount = calculateTotal(subtotal, discountAmount);
        
        // 5. Create Order entity
        Order order = buildOrder(storeId, customer.getId(), totalAmount, request, createdBy);
        Order savedOrder = orderRepository.save(order);
        
        // 6. Create OrderItem entities
        List<OrderItem> orderItems = persistOrderItems(savedOrder.getId(), itemDataList);
        
        // 7. Reduce inventory and record movements
        reduceInventory(storeId, itemDataList, savedOrder.getId());
        
        // 8. Create Debt record (if not CASH payment)
        if (!Order.PaymentType.CASH.toString().equals(request.getPaymentType())) {
            createDebtRecord(storeId, savedOrder, customer);
        }
        
        // 9. Send Notification (Async)
        try {
            String topic = "store_" + storeId + "_orders";
            String title = "Đơn hàng mới: " + savedOrder.getOrderNumber();
            String body = "Khách hàng: " + customer.getName() + " - Tổng tiền: " + totalAmount;
            notificationService.sendTopicNotification(topic, title, body);
        } catch (Exception e) {
            log.warn("Failed to send notification for order {}", savedOrder.getOrderNumber(), e);
            // Don't rollback transaction if notification fails
        }
        
        // 10. Audit log
        log.info("Order created successfully: orderId={}, orderNumber={}, total={}", 
                savedOrder.getId(), savedOrder.getOrderNumber(), totalAmount);

        // 11. Convert to DTO and return
        return mapToDTO(savedOrder, orderItems);
    }

    public Page<OrderDTO> getAllOrders(String status, LocalDate startDate, LocalDate endDate, Long customerId, Pageable pageable) {
        Long storeId = UserContext.getCurrentStoreId();
        // TODO: Implement filtering logic with Specification or QueryDSL
        // For now, just return all orders for the store
        Page<Order> orders = orderRepository.findByStoreId(storeId, pageable);
        return orders.map(order -> {
            List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
            return mapToDTO(order, items);
        });
    }

    public OrderDTO getOrderById(Long id) {
        Long storeId = UserContext.getCurrentStoreId();
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found: " + id));
        
        if (!order.getStoreId().equals(storeId)) {
            throw new BusinessException(4003, "Order does not belong to your store");
        }

        List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
        return mapToDTO(order, items);
    }

    // ========== PRIVATE METHODS (Single responsibility principle) ==========

    /**
     * Validation step: Check customer exists in user's store
     * Throws ResourceNotFoundException if customer not found or belongs to different store
     */
    private Customer validateCustomerExists(Long customerId, Long storeId) {
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found: " + customerId));
        
        // CRITICAL: Verify customer belongs to current store
        // Prevents accessing other store's customer data
        if (!customer.getStoreId().equals(storeId)) {
            throw new BusinessException(4003, "Customer does not belong to your store");
        }
        
        return customer;
    }

    /**
     * Validation step: Check order has at least one item
     */
    private List<CreateOrderRequest.OrderItemRequest> validateOrderItems(
            List<CreateOrderRequest.OrderItemRequest> items) {
        if (items == null || items.isEmpty()) {
            throw new BusinessException(4002, "Order must contain at least one item");
        }
        return items;
    }

    /**
     * Validation + Construction step: Check stock availability for all items
     * Returns OrderItemData with product info and inventory details
     */
    private List<OrderItemData> checkAndBuildOrderItems(
            List<CreateOrderRequest.OrderItemRequest> itemRequests, Long storeId) {
        
        List<OrderItemData> itemDataList = new ArrayList<>();

        for (CreateOrderRequest.OrderItemRequest itemRequest : itemRequests) {
            // 1. Find product
            Product product = productRepository.findById(itemRequest.getProductId())
                    .orElseThrow(() -> new ResourceNotFoundException("Product not found: " + itemRequest.getProductId()));
            
            // 2. Verify product belongs to user's store
            if (!product.getStoreId().equals(storeId)) {
                throw new BusinessException(4003, "Product does not belong to your store");
            }
            
            // 3. Check inventory
            Inventory inventory = inventoryRepository.findByStoreIdAndProductId(storeId, product.getId())
                    .orElseThrow(() -> new BusinessException(4005, "Product has no inventory: " + product.getSku()));
            
            // 4. Check sufficient stock
            if (inventory.getAvailableQuantity() < itemRequest.getQuantity()) {
                throw new BusinessException(4006, 
                        String.format("Insufficient stock for %s. Available: %d, Required: %d",
                                product.getName(), inventory.getAvailableQuantity(), itemRequest.getQuantity()));
            }
            
            // 5. Build OrderItemData (holds product + quantity + price)
            OrderItemData itemData = OrderItemData.builder()
                    .product(product)
                    .quantity(itemRequest.getQuantity())
                    .unitPrice(product.getPrice())
                    .totalAmount(product.getPrice().multiply(new BigDecimal(itemRequest.getQuantity())))
                    .build();
            
            itemDataList.add(itemData);
        }

        return itemDataList;
    }

    /**
     * Calculation step: Sum up all item subtotals
     */
    private BigDecimal calculateSubtotal(List<OrderItemData> itemDataList) {
        return itemDataList.stream()
                .map(OrderItemData::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    /**
     * Calculation step: Final total = subtotal - discount
     */
    private BigDecimal calculateTotal(BigDecimal subtotal, BigDecimal discountAmount) {
        BigDecimal total = subtotal.subtract(discountAmount);
        if (total.compareTo(BigDecimal.ZERO) < 0) {
            throw new BusinessException(4007, "Discount cannot exceed subtotal");
        }
        return total;
    }

    /**
     * Construction step: Build Order entity from request and validated data
     */
    private Order buildOrder(Long storeId, Long customerId, BigDecimal totalAmount,
                            CreateOrderRequest request, String createdBy) {
        String orderNumber = generateOrderNumber(storeId);
        
        return Order.builder()
                .storeId(storeId)
                .orderNumber(orderNumber)
                .customerId(customerId)
                .employeeId(UserContext.getCurrentUserId())
                .subtotal(request.getDiscountAmount() != null ? 
                        totalAmount.add(request.getDiscountAmount()) : totalAmount)
                .discountAmount(request.getDiscountAmount() != null ? 
                        request.getDiscountAmount() : BigDecimal.ZERO)
                .totalAmount(totalAmount)
                .paymentType(Order.PaymentType.valueOf(request.getPaymentType() != null ? 
                        request.getPaymentType() : "CASH"))
                .status(Order.OrderStatus.CONFIRMED)
                .notes(request.getNotes())
                .createdBy(createdBy)
                .createdAt(LocalDateTime.now())
                .build();
    }

    /**
     * Persistence step: Save all OrderItem entities
     */
    private List<OrderItem> persistOrderItems(Long orderId, List<OrderItemData> itemDataList) {
        List<OrderItem> orderItems = new ArrayList<>();

        for (OrderItemData itemData : itemDataList) {
            OrderItem orderItem = OrderItem.builder()
                    .orderId(orderId)
                    .productId(itemData.getProduct().getId())
                    .quantity(itemData.getQuantity())
                    .unitPrice(itemData.getUnitPrice())
                    .totalAmount(itemData.getTotalAmount())
                    .createdAt(LocalDateTime.now())
                    .build();

            OrderItem saved = orderItemRepository.save(orderItem);
            orderItems.add(saved);
        }

        return orderItems;
    }

    /**
     * Side effect step: Reduce inventory and create stock movement records
     * This ensures audit trail of all stock changes
     */
    private void reduceInventory(Long storeId, List<OrderItemData> itemDataList, Long orderId) {
        for (OrderItemData itemData : itemDataList) {
            Product product = itemData.getProduct();
            
            // 1. Update inventory
            Inventory inventory = inventoryRepository.findByStoreIdAndProductId(storeId, product.getId())
                    .orElseThrow();
            
            inventory.setQuantity(inventory.getQuantity() - itemData.getQuantity());
            inventory.setAvailableQuantity(inventory.getAvailableQuantity() - itemData.getQuantity());
            inventoryRepository.save(inventory);
            
            // 2. Create stock movement record (audit trail)
            StockMovement movement = StockMovement.builder()
                    .storeId(storeId)
                    .productId(product.getId())
                    .type(StockMovement.MovementType.SALE)
                    .quantity(-itemData.getQuantity()) // Negative = decrease
                    .referenceId(orderId)
                    .referenceType("ORDER")
                    .unitPrice(product.getPrice())
                    .createdBy(UserContext.getCurrentUsername())
                    .createdAt(LocalDateTime.now())
                    .build();
            
            stockMovementRepository.save(movement);
        }
    }

    /**
     * Side effect step: Create Debt record for CREDIT orders
     * Customer owes money until payment is made
     */
    private void createDebtRecord(Long storeId, Order order, Customer customer) {
        Debt debt = Debt.builder()
                .storeId(storeId)
                .orderId(order.getId())
                .customerId(customer.getId())
                .originalAmount(order.getTotalAmount())
                .paidAmount(BigDecimal.ZERO)
                .unpaidAmount(order.getTotalAmount())
                .status(Debt.DebtStatus.UNPAID)
                .dueDate(LocalDateTime.now().plusDays(30).toLocalDate())
                .createdAt(LocalDateTime.now())
                .build();
        
        debtRepository.save(debt);
    }

    /**
     * Generate unique order number per store
     * Format: ORD-STOREID-YYYYMMDD-XXX
     */
    private String generateOrderNumber(Long storeId) {
        return String.format("ORD-%d-%s-%04d",
                storeId,
                java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd")),
                System.nanoTime() % 10000);
    }

    /**
     * Map Order + OrderItems to DTO for response
     */
    private OrderDTO mapToDTO(Order order, List<OrderItem> orderItems) {
        List<OrderDTO.OrderItemDTO> itemDTOs = orderItems.stream()
                .map(item -> OrderDTO.OrderItemDTO.builder()
                        .id(item.getId())
                        .productId(item.getProductId())
                        .quantity(item.getQuantity())
                        .unitPrice(item.getUnitPrice())
                        .totalAmount(item.getTotalAmount())
                        .build())
                .toList();

        return OrderDTO.builder()
                .id(order.getId())
                .orderNumber(order.getOrderNumber())
                .customerId(order.getCustomerId())
                .employeeId(order.getEmployeeId())
                .subtotal(order.getSubtotal())
                .discountAmount(order.getDiscountAmount())
                .totalAmount(order.getTotalAmount())
                .paymentType(order.getPaymentType().toString())
                .status(order.getStatus().toString())
                .notes(order.getNotes())
                .createdAt(order.getCreatedAt())
                .items(itemDTOs)
                .build();
    }

    // ========== INNER DATA CLASS (Temporary holder) ==========
    
    /**
     * OrderItemData: Hold item details during processing
     * (Not saved to DB, just for passing data between methods)
     */
    @lombok.Data
    @lombok.Builder
    private static class OrderItemData {
        private Product product;
        private Integer quantity;
        private BigDecimal unitPrice;
        private BigDecimal totalAmount;
    }
}
