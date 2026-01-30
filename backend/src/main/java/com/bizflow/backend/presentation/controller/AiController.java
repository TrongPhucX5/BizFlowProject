package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.usecase.AiService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
public class AiController {

    private final AiService aiService;

    @PostMapping("/chat")
    public ResponseEntity<?> chat(@RequestBody Map<String, Object> payload) {
        String message = (String) payload.get("message");
        String intent = (String) payload.get("intent");

        // Delegating to service
        Map<String, Object> result = aiService.analyzeText(message, intent);

        return ResponseEntity.ok(Map.of("result", result));
    }
}
