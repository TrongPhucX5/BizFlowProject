package com.bizflow.backend.core.usecase.impl;

import com.bizflow.backend.core.common.UserContext;
import com.bizflow.backend.core.domain.Product;
import com.bizflow.backend.core.usecase.ProductService;
import com.bizflow.backend.infrastructure.persistence.repository.ProductRepository;
import com.bizflow.backend.presentation.dto.request.CreateProductRequest;
import com.bizflow.backend.presentation.dto.response.ProductDTO;
import com.bizflow.backend.presentation.exception.ResourceNotFoundException;
import com.bizflow.backend.presentation.exception.UnauthorizedException;
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
    @Transactional
    public ProductDTO createProduct(CreateProductRequest request) {
        Long storeId = UserContext.getCurrentStoreId();
        if (storeId == null) {
            throw new UnauthorizedException("Store ID not found in context");
        }

        Product product = new Product();
        product.setStoreId(storeId);
        product.setName(request.getName());
        product.setSku(request.getSku());
        product.setPrice(request.getPrice()); // Changed from setSellingPrice to setPrice
        product.setCostPrice(request.getCostPrice()); // Changed from setCost to setCostPrice
        product.setCategoryId(request.getCategoryId());
        product.setUnitId(request.getUnitId());
        product.setDescription(request.getDescription());
        product.setImageUrl(request.getImageUrl());
        product.setStatus(Product.ProductStatus.ACTIVE);
        product.setCreatedAt(LocalDateTime.now());

        Product savedProduct = productRepository.save(product);
        return mapToDTO(savedProduct);
    }

    @Override
    public Optional<Product> getProductById(Long id) {
        Long storeId = UserContext.getCurrentStoreId();
        return productRepository.findById(id)
                .filter(p -> p.getStoreId().equals(storeId));
    }

    @Override
    public Optional<Product> getProductBySku(String sku) {
        Long storeId = UserContext.getCurrentStoreId();
        Product product = productRepository.findByStoreIdAndSku(storeId, sku);
        return Optional.ofNullable(product);
    }

    @Override
    public Page<ProductDTO> getProductsByStore(Long storeId, Pageable pageable) {
        // Ensure user can only access their own store
        Long currentStoreId = UserContext.getCurrentStoreId();
        if (!currentStoreId.equals(storeId)) {
            throw new UnauthorizedException("Cannot access products from another store");
        }
        
        return productRepository.findByStoreId(storeId, pageable)
                .map(this::mapToDTO);
    }

    @Override
    public Page<ProductDTO> searchProducts(String keyword, Long storeId, Pageable pageable) {
        // Placeholder for search implementation
        return Page.empty();
    }

    @Override
    public Page<ProductDTO> getProductsByCategory(Long categoryId, Long storeId, Pageable pageable) {
        // Placeholder for category filter
        return Page.empty();
    }

    @Override
    @Transactional
    public ProductDTO updateProduct(Long id, CreateProductRequest request) {
        Long storeId = UserContext.getCurrentStoreId();
        Product product = productRepository.findById(id)
                .filter(p -> p.getStoreId().equals(storeId))
                .orElseThrow(() -> new ResourceNotFoundException("Product not found"));

        product.setName(request.getName());
        product.setSku(request.getSku());
        product.setPrice(request.getPrice()); // Changed from setSellingPrice to setPrice
        product.setCostPrice(request.getCostPrice()); // Changed from setCost to setCostPrice
        product.setCategoryId(request.getCategoryId());
        product.setUnitId(request.getUnitId());
        product.setDescription(request.getDescription());
        product.setImageUrl(request.getImageUrl());
        product.setUpdatedAt(LocalDateTime.now());

        Product updatedProduct = productRepository.save(product);
        return mapToDTO(updatedProduct);
    }

    @Override
    @Transactional
    public ProductDTO updatePrice(Long id, Double newPrice) {
        // Placeholder
        return null;
    }

    @Override
    @Transactional
    public void deleteProduct(Long id) {
        Long storeId = UserContext.getCurrentStoreId();
        Product product = productRepository.findById(id)
                .filter(p -> p.getStoreId().equals(storeId))
                .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
        
        product.setStatus(Product.ProductStatus.INACTIVE);
        productRepository.save(product);
    }

    @Override
    public Page<ProductDTO> getAllActiveProducts(Long storeId, Pageable pageable) {
        return getProductsByStore(storeId, pageable);
    }

    private ProductDTO mapToDTO(Product product) {
        return ProductDTO.builder()
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
    }
}
