package com.bizflow.backend.infrastructure.service;

import com.bizflow.backend.core.domain.Product;
import com.bizflow.backend.core.usecase.ProductService;
import com.bizflow.backend.infrastructure.persistence.repository.ProductRepository;
import com.bizflow.backend.presentation.dto.request.CreateProductRequest;
import com.bizflow.backend.presentation.dto.response.ProductDTO;
import com.bizflow.backend.presentation.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;

    @Override
    public Page<ProductDTO> getProductsByStore(Long storeId, Pageable pageable) {
        if (storeId == null) return Page.empty(pageable);
        return productRepository.findByStoreId(storeId, pageable).map(this::mapToDTO);
    }

    @Override
    @Transactional
    public ProductDTO createProduct(CreateProductRequest request) {
        Product product = new Product();
        product.setStoreId(1L); // Hard-code tạm store 1
        product.setName(request.getName());
        product.setSku(request.getSku());
        product.setPrice(request.getPrice());
        product.setCostPrice(request.getCostPrice());
        product.setCategoryId(request.getCategoryId());

        // Lưu Unit ID và Unit Name (Nếu request có gửi lên)
        product.setUnitId(request.getUnitId());
        // Tạm thời set UnitName cứng hoặc lấy từ request nếu có, ở đây để null DB sẽ chấp nhận vì class Product không bắt buộc (trừ khi request có)
        product.setUnitName("Cái");

        product.setDescription(request.getDescription());
        product.setImageUrl(request.getImageUrl());
        product.setStatus(Product.ProductStatus.ACTIVE);
        product.setCreatedAt(LocalDateTime.now());
        product.setReorderLevel(10);

        return mapToDTO(productRepository.save(product));
    }

    @Override
    @Transactional
    public ProductDTO updateProduct(Long id, CreateProductRequest request) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found"));

        product.setName(request.getName());
        product.setSku(request.getSku());
        product.setPrice(request.getPrice());
        product.setCostPrice(request.getCostPrice());
        product.setCategoryId(request.getCategoryId());
        product.setUnitId(request.getUnitId());
        product.setDescription(request.getDescription());
        product.setImageUrl(request.getImageUrl());
        product.setUpdatedAt(LocalDateTime.now());

        return mapToDTO(productRepository.save(product));
    }

    @Override
    @Transactional
    public void deleteProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
        product.setStatus(Product.ProductStatus.INACTIVE);
        productRepository.save(product);
    }

    @Override
    public Optional<Product> getProductById(Long id) {
        return productRepository.findById(id);
    }

    // --- HÀM MAP DỮ LIỆU (ĐÃ CHỈNH SỬA KHỚP VỚI ENTITY CỦA BẠN) ---
    private ProductDTO mapToDTO(Product product) {
        return ProductDTO.builder()
                .id(product.getId())
                .name(product.getName())
                .sku(product.getSku())
                .price(product.getPrice())
                .costPrice(product.getCostPrice())

                // 1. STOCK: Entity không có cột stock, nên ta trả về 0
                // (Sau này sẽ lấy từ bảng Inventory)
                .stock(0)

                .status(product.getStatus() != null ? product.getStatus().toString() : "INACTIVE")
                .storeId(product.getStoreId())
                .description(product.getDescription())
                .imageUrl(product.getImageUrl())

                // 2. UNIT: Lấy trực tiếp từ field của Entity (bạn đã có unitName trong Product)
                .unitId(product.getUnitId())
                .unitName(product.getUnitName() != null ? product.getUnitName() : "")

                // 3. CATEGORY: Chỉ trả về ID, tên để trống tạm thời
                .categoryId(product.getCategoryId())
                .categoryName("")

                .build();
    }

    // Các hàm placeholder
    @Override public Optional<Product> getProductBySku(String sku) { return Optional.empty(); }
    @Override public Page<ProductDTO> searchProducts(String k, Long s, Pageable p) { return Page.empty(); }
    @Override public Page<ProductDTO> getProductsByCategory(Long c, Long s, Pageable p) { return Page.empty(); }
    @Override public ProductDTO updatePrice(Long id, Double p) { return null; }
    @Override public Page<ProductDTO> getAllActiveProducts(Long s, Pageable p) { return getProductsByStore(s, p); }
}