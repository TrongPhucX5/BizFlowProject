package com.bizflow.backend.infrastructure.persistence.repository;

import com.bizflow.backend.core.domain.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    Product findByStoreIdAndSku(Long storeId, String sku);

    Page<Product> findByStoreId(Long storeId, Pageable pageable);

    Page<Product> findByStoreIdAndStatus(Long storeId, Product.ProductStatus status, Pageable pageable);

    List<Product> findByCategoryId(Long categoryId);

    long countByStoreId(Long storeId);

    long countByStoreIdAndStockQuantityLessThanEqual(Long storeId, Integer quantity);

    long countByStoreIdAndStatus(Long storeId, Product.ProductStatus status);

    List<Product> findByStoreIdAndStockQuantityLessThanEqual(Long storeId, Integer quantity, Pageable pageable);

    // Tìm kiếm theo Name hoặc SKU
    Page<Product> findByStoreIdAndNameContainingIgnoreCaseOrStoreIdAndSkuContainingIgnoreCase(
            Long storeId1, String name,
            Long storeId2, String sku,
            Pageable pageable);

    List<Product> findByStoreIdAndNameContainingIgnoreCase(Long storeId, String name);
}
