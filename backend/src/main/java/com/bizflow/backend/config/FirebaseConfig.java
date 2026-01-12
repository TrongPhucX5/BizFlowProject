package com.bizflow.backend.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.IOException;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        // Kiểm tra xem Firebase đã khởi tạo chưa để tránh lỗi khởi tạo 2 lần
        if (FirebaseApp.getApps().isEmpty()) {
            // Đọc file key từ resources
            InputStream serviceAccount = getClass().getClassLoader().getResourceAsStream("serviceAccountKey.json");

            if (serviceAccount == null) {
                throw new IllegalStateException("File serviceAccountKey.json không tồn tại trong resources!");
            }

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    // Thay thế bằng Tên Bucket của ông (Xem trong tab Storage trên web)
                    // Dạng: tên-project.appspot.com (Đừng có gs:// ở đầu)
                    .setStorageBucket("lithe-catbird-476301-p4.firebasestorage.app")
                    .build();

            return FirebaseApp.initializeApp(options);
        }
        return FirebaseApp.getInstance();
    }
}