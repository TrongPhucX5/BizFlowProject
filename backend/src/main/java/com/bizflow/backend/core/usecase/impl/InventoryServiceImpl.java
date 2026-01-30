package com.bizflow.backend.core.usecase.impl;

import com.bizflow.backend.core.common.UserContext;
import com.bizflow.backend.core.domain.Inventory;
import com.bizflow.backend.core.domain.Product;
import com.bizflow.backend.core.domain.StockMovement;
import com.bizflow.backend.core.usecase.InventoryService;
import com.bizflow.backend.infrastructure.persistence.repository.InventoryRepository;
import com.bizflow.backend.infrastructure.persistence.repository.ProductRepository;
import com.bizflow.backend.infrastructure.persistence.repository.StockMovementRepository;
import com.bizflow.backend.presentation.dto.request.ImportInventoryRequest;
import com.bizflow.backend.presentation.dto.response.ProductDTO;
import com.bizflow.backend.presentation.exception.BusinessException;
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
public class InventoryServiceImpl implements InventoryService {

    private final InventoryRepository inventoryRepository;
    private final StockMovementRepository stockMovementRepository;
    private final ProductRepository productRepository;

    @Override
    public boolean hasStock(Long productId, Integer quantity) {
        Long storeId = UserContext.getCurrentStoreId();
        return inventoryRepository.findByStoreIdAndProductId(storeId, productId)
                .map(inv -> inv.getAvailableQuantity() >= quantity)
                .orElse(false);
    }

    @Override
    public Optional<Inventory> getStock(Long productId) {
        Long storeId = UserContext.getCurrentStoreId();
        return inventoryRepository.findByStoreIdAndProductId(storeId, productId);
    }

    @Override
    public Integer getAvailableQuantity(Long productId) {
        return getStock(productId)
                .map(Inventory::getAvailableQuantity)
                .orElse(0);
    }

    @Override
    @Transactional
    public Inventory reserveStock(Long productId, Integer quantity, Long orderId) {
        // Logic for reserving stock (not implemented yet for this task)
        return null;
    }

    @Override
    @Transactional
    public Inventory releaseStock(Long productId, Integer quantity, Long orderId) {
        // Logic for releasing stock (not implemented yet for this task)
        return null;
    }

    @Override
    @Transactional
    public Inventory addStock(Long productId, Integer quantity, String reason, Long referenceId) {
        // Basic add stock logic
        return null;
    }

    @Override
    @Transactional
    public Inventory reduceStock(Long productId, Integer quantity, String reason, Long referenceId) {
        // Basic reduce stock logic
        return null;
    }

    /**
     * Import stock (Nhập hàng)
     * - Update Inventory quantity
     * - Update Product cost price
     * - Create StockMovement record
     */
    @Transactional
    @org.springframework.cache.annotation.CacheEvict(value = "products_page", allEntries = true)
    @com.bizflow.backend.core.annotation.AuditAction(action = "IMPORT_STOCK", entityType = "INVENTORY")
    public Inventory importStock(ImportInventoryRequest request) {
        Long storeId = UserContext.getCurrentStoreId();
        String username = UserContext.getCurrentUsername();

        // 1. Validate Product
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new ResourceNotFoundException("Product not found: " + request.getProductId()));

        if (!product.getStoreId().equals(storeId)) {
            throw new BusinessException(4003, "Product does not belong to your store");
        }

        // 2. Get or Create Inventory
        Inventory inventory = inventoryRepository.findByStoreIdAndProductId(storeId, request.getProductId())
                .orElseGet(() -> {
                    // Kế thừa tồn kho cũ từ cột stock_quantity trong bảng products
                    int legacyStock = product.getStockQuantity() != null ? product.getStockQuantity() : 0;
                    return Inventory.builder()
                            .storeId(storeId)
                            .productId(request.getProductId())
                            .quantity(legacyStock)
                            .reservedQuantity(0)
                            .availableQuantity(legacyStock)
                            .build();
                });

        // 3. Update Inventory
        inventory.setQuantity(inventory.getQuantity() + request.getQuantity());
        inventory.setAvailableQuantity(inventory.getAvailableQuantity() + request.getQuantity());
        // inventory.setLastRestockedAt(LocalDateTime.now()); // Removed
        Inventory savedInventory = inventoryRepository.save(inventory);

        // 4. Update Product Cost Price (Optional: could use weighted average)
        // Here we simply update to the latest import cost
        product.setCostPrice(request.getUnitCost());
        productRepository.save(product);

        // 5. Create Stock Movement (Audit Trail)
        StockMovement movement = StockMovement.builder()
                .storeId(storeId)
                .productId(request.getProductId())
                .type(StockMovement.MovementType.STOCK_IN) // Fixed: IMPORT -> STOCK_IN
                .quantity(request.getQuantity())
                .unitPrice(request.getUnitCost())
                .notes(request.getNote()) // Fixed: note -> notes
                .createdBy(username)
                .createdAt(LocalDateTime.now())
                .build();

        stockMovementRepository.save(movement);

        return savedInventory;
    }

    @Override
    public Page<ProductDTO> getStockMovementHistory(Long productId, Pageable pageable) {
        // TODO: Implement mapping to DTO
        return Page.empty();
    }

    @Override
    public Page<ProductDTO> getLowStockProducts(Long storeId, Pageable pageable) {
        // TODO: Implement query
        return Page.empty();
    }

    @Override
    @Transactional
    public Inventory adjustStock(Long productId, Integer newQuantity, String reason) {
        Long storeId = UserContext.getCurrentStoreId();
        String username = UserContext.getCurrentUsername();

        Inventory inventory = inventoryRepository.findByStoreIdAndProductId(storeId, productId)
                .orElseThrow(() -> new ResourceNotFoundException("Inventory not found for product: " + productId));

        int oldQuantity = inventory.getQuantity() != null ? inventory.getQuantity() : 0;
        int diff = newQuantity - oldQuantity;

        if (diff == 0)
            return inventory;

        inventory.setQuantity(newQuantity);
        inventory.setAvailableQuantity(
                (inventory.getAvailableQuantity() != null ? inventory.getAvailableQuantity() : 0) + diff);

        Inventory saved = inventoryRepository.save(inventory);

        // Create Movement
        StockMovement movement = StockMovement.builder()
                .storeId(storeId)
                .productId(productId)
                .type(StockMovement.MovementType.STOCK_ADJUST)
                .quantity(diff) // Signed difference
                .notes(reason)
                .createdBy(username)
                .createdAt(LocalDateTime.now())
                .build();

        stockMovementRepository.save(movement);

        return saved;
    }
}
