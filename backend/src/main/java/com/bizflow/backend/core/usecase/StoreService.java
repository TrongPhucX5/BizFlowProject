package com.bizflow.backend.core.usecase;

import com.bizflow.backend.core.domain.Store;
import com.bizflow.backend.presentation.dto.response.StoreDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface StoreService {
    Page<StoreDTO> getAllStores(String search, Pageable pageable);

    StoreDTO updateStoreStatus(Long id, Store.StoreStatus status);

    StoreDTO getStoreById(Long id);

    StoreDTO updateStoreInfo(Long id, java.util.Map<String, Object> request);

    void deleteStore(Long id);
}
