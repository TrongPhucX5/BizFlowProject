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
    List<Product> findByCategoryId(Long categoryId);
}
