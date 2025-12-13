package com.bizflow.backend.infrastructure.file;

import com.google.cloud.storage.Bucket;
import com.google.firebase.cloud.StorageClient;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@Service
public class FileService {

    public String uploadImage(MultipartFile file) throws IOException {
        // 1. Kiểm tra file rỗng để tránh lỗi 0 bytes
        if (file.isEmpty()) {
            throw new IOException("File không được để trống!");
        }

        // 2. Lấy đuôi file chuẩn xác
        String originalFileName = file.getOriginalFilename();
        String extension = ".jpg"; // Mặc định

        if (originalFileName != null && originalFileName.contains(".")) {
            extension = originalFileName.substring(originalFileName.lastIndexOf("."));
        }

        // 3. Tạo tên file ngẫu nhiên
        String fileName = UUID.randomUUID().toString() + extension;

        // 4. Lấy Bucket
        Bucket bucket = StorageClient.getInstance().bucket();

        // 5. UPLOAD BẰNG BYTES (Quan trọng: Sửa dòng này để hết lỗi 0 bytes)
        // bucket.create(Tên file, Mảng byte dữ liệu, Kiểu file)
        bucket.create(fileName, file.getBytes(), file.getContentType());

        // 6. Trả về đường dẫn công khai
        return String.format("https://firebasestorage.googleapis.com/v0/b/%s/o/%s?alt=media", bucket.getName(), fileName);
    }
}