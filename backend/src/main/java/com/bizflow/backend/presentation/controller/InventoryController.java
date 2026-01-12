package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.domain.Inventory;
import com.bizflow.backend.core.usecase.InventoryService;
import com.bizflow.backend.presentation.dto.request.ImportInventoryRequest;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/inventory")
@RequiredArgsConstructor
public class InventoryController {

    private final InventoryService inventoryService;

    /**
     * Nhập hàng vào kho
     * POST /v1/inventory/import
     */
    @PostMapping("/import")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<Inventory>> importStock(@Valid @RequestBody ImportInventoryRequest request) {
        Inventory inventory = inventoryService.importStock(request);
        return ResponseEntity.ok(ApiResponse.success(inventory, "Nhập hàng thành công"));
    }

    /**
     * Xem tồn kho của sản phẩm
     * GET /v1/inventory/{productId}
     */
    @GetMapping("/{productId}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<Inventory>> getStock(@PathVariable Long productId) {
        return inventoryService.getStock(productId)
                .map(inv -> ResponseEntity.ok(ApiResponse.success(inv, "Lấy thông tin tồn kho thành công")))
                .orElse(ResponseEntity.notFound().build());
    }
}
