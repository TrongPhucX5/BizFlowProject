package com.bizflow.backend.core.usecase;

import org.springframework.web.multipart.MultipartFile;

public interface StorageService {
    /**
     * Upload file to cloud storage
     * 
     * @param file File to upload
     * @return Public URL of the uploaded file
     */
    String uploadFile(MultipartFile file);
}
