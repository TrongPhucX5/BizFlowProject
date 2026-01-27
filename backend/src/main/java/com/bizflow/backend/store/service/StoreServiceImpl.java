package com.bizflow.backend.store.service;

import com.bizflow.backend.core.domain.Store;
import com.bizflow.backend.core.usecase.StoreService;
import com.bizflow.backend.infrastructure.persistence.repository.StoreRepository;
import com.bizflow.backend.presentation.dto.response.StoreDTO;
import com.bizflow.backend.presentation.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class StoreServiceImpl implements StoreService {

    private final StoreRepository storeRepository;

    @Override
    public Page<StoreDTO> getAllStores(String search, Pageable pageable) {
        Page<Store> stores;
        if (search != null && !search.trim().isEmpty()) {
            stores = storeRepository.searchStores(search.trim(), pageable);
        } else {
            stores = storeRepository.findAll(pageable);
        }
        return stores.map(this::mapToDTO);
    }

    @Override
    public StoreDTO updateStoreStatus(Long id, Store.StoreStatus status) {
        Store store = storeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Store not found with id: " + id));
        store.setStatus(status);
        store = storeRepository.save(store);
        return mapToDTO(store);
    }

    @Override
    public StoreDTO getStoreById(Long id) {
        Store store = storeRepository.findById(id)
                 .orElseThrow(() -> new ResourceNotFoundException("Store not found with id: " + id));
        return mapToDTO(store);
    }

    private StoreDTO mapToDTO(Store store) {
        return StoreDTO.builder()
                .id(store.getId())
                .name(store.getName())
                .address(store.getAddress())
                .phone(store.getPhone())
                .email(store.getEmail())
                .taxCode(store.getTaxCode())
                .status(store.getStatus().toString())
                .createdAt(store.getCreatedAt())
                .updatedAt(store.getUpdatedAt())
                .build();
    }
}
