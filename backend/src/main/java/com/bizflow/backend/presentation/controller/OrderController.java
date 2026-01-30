package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.usecase.OrderService;
import com.bizflow.backend.presentation.dto.request.CreateOrderRequest;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.presentation.dto.response.OrderDTO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/v1/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    /**
     * Lấy danh sách đơn hàng có phân trang và lọc
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<Page<OrderDTO>>> getAllOrders(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String customerId,
            Pageable pageable) {

        Page<OrderDTO> orders = orderService.getAllOrders(status, startDate, endDate, customerId, pageable);
        return ResponseEntity.ok(ApiResponse.success(orders, "Lấy danh sách đơn hàng thành công"));
    }

    /**
     * Lấy chi tiết một đơn hàng theo ID
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<OrderDTO>> getOrderById(@PathVariable Long id) {
        OrderDTO order = orderService.getOrderById(id);
        return ResponseEntity.ok(ApiResponse.success(order, "Lấy thông tin đơn hàng thành công"));
    }

    /**
     * Tạo mới một đơn hàng
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<OrderDTO>> createOrder(@Valid @RequestBody CreateOrderRequest request) {
        OrderDTO order = orderService.createOrder(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(order, "Tạo đơn hàng thành công"));
    }

    // @PutMapping("/{id}")
    // @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    // public ResponseEntity<ApiResponse<OrderDTO>> updateOrder(
    // @PathVariable Long id,
    // @Valid @RequestBody CreateOrderRequest request) {

    // OrderDTO order = orderService.updateOrder(id, request);
    // return ResponseEntity.ok(ApiResponse.success(order, "Order updated
    // successfully"));
    // }
    /**
     * Chỉnh sửa đơn hàng (Hoàn kho cũ, trừ kho mới)
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<OrderDTO>> updateOrder(
            @PathVariable Long id,
            @Valid @RequestBody CreateOrderRequest request) {

        OrderDTO order = orderService.updateOrder(id, request);
        return ResponseEntity.ok(ApiResponse.success(order, "Cập nhật đơn hàng thành công"));
    }
    // @DeleteMapping("/{id}")
    // @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    // public ResponseEntity<ApiResponse<Void>> deleteOrder(@PathVariable Long id) {
    // orderService.deleteOrder(id);
    // return ResponseEntity.ok(ApiResponse.success(null, "Order deleted
    // successfully"));
    // }

    /**
     * Hủy đơn hàng và hoàn trả tồn kho
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteOrder(@PathVariable Long id) {
        orderService.cancelOrder(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Hủy đơn hàng thành công"));
    }

    /**
     * In hóa đơn - Trả về HTML format
     */
    @GetMapping("/{id}/print")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<String>> printOrder(@PathVariable Long id) {
        OrderDTO order = orderService.getOrderById(id);
        String htmlInvoice = generateInvoiceHtml(order);
        return ResponseEntity.ok(ApiResponse.success(htmlInvoice, "Lấy hóa đơn thành công"));
    }

    /**
     * Generate simple HTML invoice
     */
    private String generateInvoiceHtml(OrderDTO order) {
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html><html><head><meta charset='UTF-8'>");
        html.append("<style>");
        html.append("body{font-family:Arial,sans-serif;padding:20px;max-width:400px;margin:0 auto;}");
        html.append(".header{text-align:center;border-bottom:2px dashed #333;padding-bottom:10px;}");
        html.append(".item{display:flex;justify-content:space-between;padding:5px 0;}");
        html.append(".total{border-top:2px dashed #333;padding-top:10px;font-weight:bold;}");
        html.append("</style></head><body>");

        // Header
        html.append("<div class='header'>");
        html.append("<h2>HÓA ĐƠN BÁN HÀNG</h2>");
        html.append("<p>Mã đơn: ").append(order.getOrderCode() != null ? order.getOrderCode() : "#" + order.getId())
                .append("</p>");
        html.append("<p>Ngày: ").append(order.getCreatedAt() != null ? order.getCreatedAt().toString() : "N/A")
                .append("</p>");
        html.append("</div>");

        // Customer
        html.append("<div style='margin:15px 0;'>");
        html.append("<p><strong>Khách hàng:</strong> ")
                .append(order.getCustomerName() != null ? order.getCustomerName() : "Khách lẻ").append("</p>");
        html.append("</div>");

        // Items
        html.append("<div style='margin:15px 0;'>");
        if (order.getItems() != null) {
            for (var item : order.getItems()) {
                html.append("<div class='item'>");
                html.append("<span>").append(item.getProductName()).append(" x").append(item.getQuantity())
                        .append("</span>");
                html.append("<span>").append(String.format("%,.0f đ", item.getSubtotal())).append("</span>");
                html.append("</div>");
            }
        }
        html.append("</div>");

        // Total
        html.append("<div class='total'>");
        html.append("<div class='item'><span>TỔNG CỘNG:</span><span>")
                .append(String.format("%,.0f đ", order.getTotalAmount())).append("</span></div>");
        html.append("</div>");

        // Footer
        html.append("<div style='text-align:center;margin-top:20px;'>");
        html.append("<p>Cảm ơn quý khách!</p>");
        html.append("</div>");

        html.append("</body></html>");
        return html.toString();
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<OrderDTO>> updateOrderStatus(
            @PathVariable Long id,
            @RequestParam String status) {

        OrderDTO order = orderService.updateOrderStatus(id, status);
        return ResponseEntity.ok(ApiResponse.success(order, "Cập nhật trạng thái thành công"));
    }

    // @PostMapping("/{id}/pay")
    // @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    // public ResponseEntity<ApiResponse<OrderDTO>> makePayment(
    // @PathVariable Long id,
    // @RequestBody PaymentRequest paymentRequest) {

    // OrderDTO order = orderService.makePayment(id, paymentRequest);
    // return ResponseEntity.ok(ApiResponse.success(order, "Payment processed
    // successfully"));
    // }

    // @GetMapping("/today")
    // @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    // public ResponseEntity<ApiResponse<Page<OrderDTO>>> getTodayOrders(Pageable
    // pageable) {
    // Page<OrderDTO> orders = orderService.getTodayOrders(pageable);
    // return ResponseEntity.ok(ApiResponse.success(orders, "Today's orders
    // retrieved successfully"));
    // }
}

// PaymentRequest DTO
record PaymentRequest(
        Double amount,
        String paymentMethod,
        String transactionId,
        String note) {
}
