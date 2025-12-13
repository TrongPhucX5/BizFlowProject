package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.Product;
import com.bizflow.backend.presentation.dto.request.CreateProductRequest;
import com.bizflow.backend.presentation.dto.response.ProductDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;

/**
 * ProductService: Product management
 * 
 * RESPONSIBILITIES:
 * 1. CRUD operations on products
 * 2. Search and filter by category, store
 * 3. Price history management
 * 4. Stock integration
 * 
 * PATTERN:
 * - Validate input → Check business rules → Build entity → Persist → Return DTO
 * 
 * SECURITY:
 * - All operations enforce store_id isolation (UserContext)
 * - Only OWNER/ADMIN can modify products
 */
public interface ProductService {

    /**
     * Create new product
     * 
     * @param request Product details
     * @return Created product DTO
     * @throws BusinessException if validation fails
     */
    ProductDTO createProduct(CreateProductRequest request);

    /**
     * Get product by ID (with store filter)
     * 
     * @param id Product ID
     * @return Product DTO or empty
     */
    Optional<Product> getProductById(Long id);

    /**
     * Get product by SKU (with store filter)
     * 
     * @param sku Product SKU
     * @return Product DTO or empty
     */
    Optional<Product> getProductBySku(String sku);

    /**
     * List products by store (paginated)
     * 
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of products
     */
    Page<ProductDTO> getProductsByStore(Long storeId, Pageable pageable);

    /**
     * Search products by name/SKU (with store filter)
     * 
     * @param keyword Search keyword
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of matching products
     */
    Page<ProductDTO> searchProducts(String keyword, Long storeId, Pageable pageable);

    /**
     * Get products by category (with store filter)
     * 
     * @param categoryId Category ID
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of products
     */
    Page<ProductDTO> getProductsByCategory(Long categoryId, Long storeId, Pageable pageable);

    /**
     * Update product details
     * 
     * @param id Product ID
     * @param request Update details
     * @return Updated product DTO
     * @throws ResourceNotFoundException if product not found
     */
    ProductDTO updateProduct(Long id, CreateProductRequest request);

    /**
     * Update product price
     * 
     * @param id Product ID
     * @param newPrice New selling price
     * @return Updated product DTO
     * @throws ResourceNotFoundException if product not found
     */
    ProductDTO updatePrice(Long id, Double newPrice);

    /**
     * Delete product (soft delete via status = INACTIVE)
     * 
     * @param id Product ID
     * @throws ResourceNotFoundException if product not found
     */
    void deleteProduct(Long id);

    /**
     * Get all active products for store
     * 
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of active products
     */
    Page<ProductDTO> getAllActiveProducts(Long storeId, Pageable pageable);
}
