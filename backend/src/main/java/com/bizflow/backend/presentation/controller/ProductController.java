package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.common.UserContext;
import com.bizflow.backend.core.usecase.ProductService;
import com.bizflow.backend.presentation.dto.request.CreateProductRequest;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import com.bizflow.backend.presentation.dto.response.ProductDTO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @PostMapping
    // TẠM THỜI: Cho phép cả EMPLOYEE thêm sản phẩm để bạn test
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<ProductDTO>> createProduct(@Valid @RequestBody CreateProductRequest request) {
        ProductDTO product = productService.createProduct(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(product, "Product created successfully"));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Page<ProductDTO>>> getProducts(
            @PageableDefault(size = 20) Pageable pageable) {
        Long storeId = UserContext.getCurrentStoreId();
        Page<ProductDTO> products = productService.getProductsByStore(storeId, pageable);
        return ResponseEntity.ok(ApiResponse.success(products, "Products retrieved successfully"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ProductDTO>> getProduct(@PathVariable Long id) {
        return productService.getProductById(id)
                .map(product -> {
                    ProductDTO dto = ProductDTO.builder()
                            .id(product.getId())
                            .name(product.getName())
                            .sku(product.getSku())
                            .price(product.getPrice()) // Changed from getSellingPrice to getPrice
                            .costPrice(product.getCostPrice()) // Changed from getCost to getCostPrice
                            .categoryId(product.getCategoryId())
                            .unitId(product.getUnitId())
                            .description(product.getDescription())
                            .imageUrl(product.getImageUrl())
                            .status(product.getStatus().toString())
                            .storeId(product.getStoreId())
                            .build();
                    return ResponseEntity.ok(ApiResponse.success(dto, "Product retrieved successfully"));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<ProductDTO>> updateProduct(
            @PathVariable Long id,
            @Valid @RequestBody CreateProductRequest request) {
        ProductDTO product = productService.updateProduct(id, request);
        return ResponseEntity.ok(ApiResponse.success(product, "Product updated successfully"));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Product deleted successfully"));
    }
}
