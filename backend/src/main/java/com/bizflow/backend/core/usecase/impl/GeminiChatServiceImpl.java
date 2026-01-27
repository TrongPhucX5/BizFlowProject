package com.bizflow.backend.core.usecase.impl;

import com.bizflow.backend.core.usecase.GeminiChatUseCase;
import org.springframework.stereotype.Service;

@Service // QUAN TRỌNG: Annotation này giúp Spring tạo ra Bean
public class GeminiChatServiceImpl implements GeminiChatUseCase {

    @Override
    public String chat(String prompt) {
        // Tạm thời trả về chuỗi giả lập để hệ thống khởi động được
        return "Gemini AI: Hệ thống đã kết nối thành công! Bạn vừa hỏi: " + prompt;
    }
}