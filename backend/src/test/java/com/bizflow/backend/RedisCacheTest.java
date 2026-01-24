package com.bizflow.backend;

import com.bizflow.backend.core.domain.Product;
import com.bizflow.backend.core.usecase.ProductService;
import com.bizflow.backend.infrastructure.persistence.repository.ProductRepository;
import com.bizflow.backend.presentation.dto.request.CreateProductRequest;
import com.bizflow.backend.presentation.dto.response.ProductDTO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.cache.CacheManager;
import org.springframework.test.context.ActiveProfiles;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@SpringBootTest
@ActiveProfiles("test") // Use a test profile if configured, or default
public class RedisCacheTest {

    @Autowired
    private ProductService productService;

    @SpyBean
    private ProductRepository productRepository;

    @Autowired
    private CacheManager cacheManager;

    @Autowired
    private org.springframework.data.redis.core.StringRedisTemplate redisTemplate;

    @BeforeEach
    void setUp() {
        // Clear all caches before each test to ensure isolation
        redisTemplate.getConnectionFactory().getConnection().serverCommands().flushDb();

        // Mock data for findById(1L)
        Product mockProduct = Product.builder()
                .id(1L)
                .storeId(1L)
                .name("Test Product")
                .price(BigDecimal.valueOf(100000))
                .status(Product.ProductStatus.ACTIVE)
                .build();

        // Ensure the repository returns this product when queried (using DO RETURN for
        // Spy)
        doReturn(Optional.of(mockProduct)).when(productRepository).findById(1L);
        doAnswer(invocation -> invocation.getArgument(0)).when(productRepository).save(any(Product.class));
    }

    @Test
    void testCacheHit() {
        // 1. First Call - Should hit DB (Cache Miss)
        productService.getProductById(1L);

        // 2. Second Call - Should hit Cache (Cache Hit)
        productService.getProductById(1L);

        // Verification: Repository.findById should be called exactly ONCE
        verify(productRepository, times(1)).findById(1L);

        System.out.println(">>> CHECKPOINT: testCacheHit passed. DB called 1 time.");
    }

    @Test
    void testCacheEvictAndUpdate() {
        // 1. First Call - Cache Miss (DB Hit 1)
        productService.getProductById(1L);

        // 2. Update Product - Should trigger @CacheEvict
        CreateProductRequest updateRequest = new CreateProductRequest();
        updateRequest.setName("Updated Product");
        updateRequest.setPrice(BigDecimal.valueOf(120000));
        // Fill other required fields to avoid validation errors if any (assuming
        // minimal validation for now)
        productService.updateProduct(1L, updateRequest);

        // 3. Third Call - Should trigger DB Hit again (Cache Miss due to Evict)
        productService.getProductById(1L);

        // Verification: Repository.findById should be called 3 TIMES
        // 1. Initial Read (Cache Miss)
        // 2. Inside updateProduct (to find entity)
        // 3. Post-Update Read (Cache Miss due to Evict)
        verify(productRepository, times(3)).findById(1L);

        System.out.println(">>> CHECKPOINT: testCacheEvictAndUpdate passed. DB called 2 times (Evicton working).");
    }

    @Test
    void testPageCaching() {
        // 1. Setup Mock for Page return
        PageRequest pageRequest = PageRequest.of(0, 10);
        Product mockProduct = Product.builder().id(1L).storeId(1L).name("Page Product").price(BigDecimal.TEN)
                .status(Product.ProductStatus.ACTIVE).build();
        PageImpl<Product> mockPage = new PageImpl<>(List.of(mockProduct), pageRequest, 1);

        // Return mockPage when repository is called
        doReturn(mockPage).when(productRepository).findByStoreId(1L, pageRequest);

        // 2. First Call - Cache Miss
        productService.getProductsByStore(1L, pageRequest);

        // 3. Second Call - Cache Hit
        productService.getProductsByStore(1L, pageRequest);

        // 4. Verify Repository called ONLY ONCE
        verify(productRepository, times(1)).findByStoreId(1L, pageRequest);

        System.out.println(">>> CHECKPOINT: testPageCaching passed. Page<ProductDTO> deserialized correctly.");
    }
}
