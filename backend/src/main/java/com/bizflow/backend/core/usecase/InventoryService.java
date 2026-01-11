package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.Inventory;
import com.bizflow.backend.presentation.dto.request.ImportInventoryRequest;
import com.bizflow.backend.presentation.dto.response.ProductDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;

/**
 * InventoryService: Inventory and stock management
 * 
 * RESPONSIBILITIES:
 * 1. Check stock availability
 * 2. Reserve stock for orders
 * 3. Release reserved stock
 * 4. Record stock movements (IN/OUT)
 * 5. Track stock history
 * 
 * PATTERN:
 * - Validate input → Check business rules → Build entity → Persist → Return DTO
 * 
 * SECURITY:
 * - All operations enforce store_id isolation (UserContext)
 * - Only OWNER/WAREHOUSE can modify stock
 * - Stock movements are immutable (audit trail)
 */
public interface InventoryService {

    /**
     * Check if product has sufficient stock
     * 
     * @param productId Product ID
     * @param quantity Required quantity
     * @return true if stock available
     */
    boolean hasStock(Long productId, Integer quantity);

    /**
     * Get current stock for product
     * 
     * @param productId Product ID
     * @return Inventory info or empty
     */
    Optional<Inventory> getStock(Long productId);

    /**
     * Get available quantity (total - reserved)
     * 
     * @param productId Product ID
     * @return Available quantity
     */
    Integer getAvailableQuantity(Long productId);

    /**
     * Reserve stock for order
     * Creates reserved stock movement entry
     * Does NOT deduct from total stock
     * 
     * @param productId Product ID
     * @param quantity Quantity to reserve
     * @param orderId Related order ID
     * @return Updated inventory
     * @throws BusinessException if insufficient stock
     */
    Inventory reserveStock(Long productId, Integer quantity, Long orderId);

    /**
     * Release reserved stock (cancel order)
     * 
     * @param productId Product ID
     * @param quantity Quantity to release
     * @param orderId Related order ID
     * @return Updated inventory
     */
    Inventory releaseStock(Long productId, Integer quantity, Long orderId);

    /**
     * Record stock IN movement
     * 
     * @param productId Product ID
     * @param quantity Quantity added
     * @param reason IN reason (PURCHASE, RETURN, ADJUSTMENT)
     * @param referenceId Related document ID
     * @return Updated inventory
     */
    Inventory addStock(Long productId, Integer quantity, String reason, Long referenceId);

    /**
     * Record stock OUT movement
     * 
     * @param productId Product ID
     * @param quantity Quantity removed
     * @param reason OUT reason (SALE, DAMAGE, ADJUSTMENT)
     * @param referenceId Related document ID
     * @return Updated inventory
     * @throws BusinessException if insufficient stock
     */
    Inventory reduceStock(Long productId, Integer quantity, String reason, Long referenceId);

    /**
     * Import stock (Nhập hàng)
     * 
     * @param request Import details
     * @return Updated inventory
     */
    Inventory importStock(ImportInventoryRequest request);

    /**
     * Get stock movement history for product
     * 
     * @param productId Product ID
     * @param pageable Pagination info
     * @return Page of stock movements
     */
    Page<ProductDTO> getStockMovementHistory(Long productId, Pageable pageable);

    /**
     * Get low stock products (quantity < minimum level)
     * 
     * @param storeId Store ID
     * @param pageable Pagination info
     * @return Page of low stock products
     */
    Page<ProductDTO> getLowStockProducts(Long storeId, Pageable pageable);

    /**
     * Adjust stock quantity (admin only)
     * 
     * @param productId Product ID
     * @param newQuantity New total quantity
     * @param reason Adjustment reason
     * @return Updated inventory
     */
    Inventory adjustStock(Long productId, Integer newQuantity, String reason);
}
