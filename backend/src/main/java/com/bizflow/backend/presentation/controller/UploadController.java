package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.usecase.StorageService;
import com.bizflow.backend.presentation.dto.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/v1/upload")
@RequiredArgsConstructor
public class UploadController {

    private final StorageService storageService;

    @PostMapping(value = "/image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN', 'EMPLOYEE')")
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadFile(
            @RequestParam("file") MultipartFile file) {
        
        String fileUrl = storageService.uploadFile(file);
        
        return ResponseEntity.ok(ApiResponse.success(
                Map.of("url", fileUrl),
                "Upload file thành công"
        ));
    }
}
