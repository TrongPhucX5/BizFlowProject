package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.domain.Store;
import com.bizflow.backend.core.usecase.StoreService;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.presentation.dto.response.StoreDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/v1/stores")
@RequiredArgsConstructor
public class StoreController {

    private final StoreService storeService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Page<StoreDTO>>> getAllStores(
            @RequestParam(required = false) String search,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<StoreDTO> stores = storeService.getAllStores(search, pageable);
        return ResponseEntity.ok(ApiResponse.success(stores, "Danh sách cửa hàng"));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<StoreDTO>> getStoreById(@PathVariable Long id) {
        StoreDTO store = storeService.getStoreById(id);
        return ResponseEntity.ok(ApiResponse.success(store, "Chi tiết cửa hàng"));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<StoreDTO>> updateStoreStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        String statusStr = request.get("status");
        Store.StoreStatus status = Store.StoreStatus.valueOf(statusStr);
        StoreDTO updatedStore = storeService.updateStoreStatus(id, status);
        return ResponseEntity.ok(ApiResponse.success(updatedStore, "Cập nhật trạng thái thành công"));
    }
}
