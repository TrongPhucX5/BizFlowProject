package com.bizflow.backend.core.usecase.impl;

import com.bizflow.backend.core.usecase.StorageService;
import com.bizflow.backend.presentation.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Base64;

@Slf4j
@Service
@RequiredArgsConstructor
public class StorageServiceImpl implements StorageService {

    @Override
    public String uploadFile(MultipartFile file) {
        if (file.isEmpty()) {
            throw new BusinessException(400, "File is empty");
        }

        // Check file size (e.g., limit to 2MB to avoid DB bloat)
        if (file.getSize() > 2 * 1024 * 1024) {
            throw new BusinessException(400, "File size exceeds 2MB limit");
        }

        try {
            byte[] fileBytes = file.getBytes();
            String base64Encoded = Base64.getEncoder().encodeToString(fileBytes);
            
            // Return Data URI format: data:[<mediatype>][;base64],<data>
            return "data:" + file.getContentType() + ";base64," + base64Encoded;

        } catch (IOException e) {
            log.error("Error converting file to Base64", e);
            throw new BusinessException(500, "Could not process file");
        }
    }
}
