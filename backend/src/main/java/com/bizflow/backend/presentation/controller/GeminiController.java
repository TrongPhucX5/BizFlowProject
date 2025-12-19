package com.bizflow.backend.presentation.controller;

import com.bizflow.backend.core.usecase.GeminiChatUseCase;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/ai")
public class GeminiController {

    private final GeminiChatUseCase geminiChatUseCase;

    public GeminiController(GeminiChatUseCase geminiChatUseCase) {
        this.geminiChatUseCase = geminiChatUseCase;
    }

    @PostMapping("/chat")
    public Map<String, String> chat(@RequestBody Map<String, String> body) {
        String prompt = body.get("prompt");
        return Map.of(
                "answer",
                geminiChatUseCase.chat(prompt)
        );
    }
    //@GetMapping("/test")
    //public String test() {
    //return geminiChatUseCase.chat("Test Gemini");
    //}

}