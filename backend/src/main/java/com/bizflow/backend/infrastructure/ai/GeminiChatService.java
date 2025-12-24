package com.bizflow.backend.infrastructure.ai;

import com.bizflow.backend.core.usecase.GeminiChatUseCase;
import com.google.gson.*;
import okhttp3.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
public class GeminiChatService implements GeminiChatUseCase {

    @Value("${gemini.api.key}")
    private String apiKey;

    // Mặc định thử dùng con này trước
    private static final String BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models/";
    private String currentModel = "gemini-2.0-flash";

    @Override
    public String chat(String prompt) {
        try {
            OkHttpClient client = new OkHttpClient();
            String url = BASE_URL + currentModel + ":generateContent?key=" + apiKey;

            // 1. Tạo JSON Body
            JsonObject text = new JsonObject();
            text.addProperty("text", prompt);
            JsonArray parts = new JsonArray();
            parts.add(text);
            JsonObject content = new JsonObject();
            content.add("parts", parts);
            JsonArray contents = new JsonArray();
            contents.add(content);
            JsonObject body = new JsonObject();
            body.add("contents", contents);

            Request request = new Request.Builder()
                    .url(url)
                    .post(RequestBody.create(body.toString(), MediaType.parse("application/json")))
                    .build();

            // 2. Gọi API
            try (Response response = client.newCall(request).execute()) {
                String responseBody = response.body().string();

                // --- NẾU LỖI 404 (Không tìm thấy model) ---
                if (response.code() == 404) {
                    System.err.println(">>> LỖI 404: Model '" + currentModel + "' không khả dụng với Key này.");
                    System.out.println(">>> ĐANG TỰ ĐỘNG QUÉT CÁC MODEL KHẢ DỤNG...");

                    // Gọi hàm kiểm tra danh sách model
                    checkAvailableModels(client);

                    return "Lỗi 404: Model không đúng. Hãy xem Console Log (cửa sổ chạy code) để thấy danh sách model mà Key của ông dùng được!";
                }

                if (!response.isSuccessful()) {
                    System.out.println("DEBUG BODY: " + responseBody);
                    return "Lỗi Google (" + response.code() + "): " + responseBody;
                }

                // 3. Xử lý kết quả thành công
                JsonObject root = JsonParser.parseString(responseBody).getAsJsonObject();
                if (root.has("candidates") && root.getAsJsonArray("candidates").size() > 0) {
                    JsonObject candidate = root.getAsJsonArray("candidates").get(0).getAsJsonObject();
                    if (candidate.has("content")) {
                        return candidate.getAsJsonObject("content")
                                .getAsJsonArray("parts")
                                .get(0).getAsJsonObject()
                                .get("text").getAsString();
                    }
                }
                return "AI không trả lời được.";
            }

        } catch (Exception e) {
            e.printStackTrace();
            return "Lỗi Server: " + e.getMessage();
        }
    }

    // --- HÀM PHỤ: HỎI GOOGLE XEM KEY NÀY DÙNG ĐƯỢC MODEL NÀO ---
    private void checkAvailableModels(OkHttpClient client) {
        try {
            Request request = new Request.Builder()
                    .url("https://generativelanguage.googleapis.com/v1beta/models?key=" + apiKey)
                    .get()
                    .build();

            try (Response response = client.newCall(request).execute()) {
                String body = response.body().string();
                System.out.println("\n============================================");
                System.out.println("DANH SÁCH MODEL MÀ KEY CỦA ÔNG ĐƯỢC DÙNG:");

                JsonObject root = JsonParser.parseString(body).getAsJsonObject();
                if (root.has("models")) {
                    JsonArray models = root.getAsJsonArray("models");
                    for (JsonElement model : models) {
                        String name = model.getAsJsonObject().get("name").getAsString();
                        // Chỉ in mấy con tạo nội dung (generateContent)
                        if (model.getAsJsonObject().toString().contains("generateContent")) {
                            System.out.println("✅ " + name.replace("models/", ""));
                        }
                    }
                } else {
                    System.out.println("❌ Không lấy được danh sách model. Lỗi: " + body);
                }
                System.out.println("============================================\n");
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi quét model: " + e.getMessage());
        }
    }
}