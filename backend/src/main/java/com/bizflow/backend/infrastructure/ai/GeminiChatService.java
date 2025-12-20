package com.bizflow.backend.infrastructure.ai;

import com.bizflow.backend.core.usecase.GeminiChatUseCase;
import com.google.gson.*;
import okhttp3.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class GeminiChatService implements GeminiChatUseCase {

    @Value("${gemini.api.key}")
    private String apiKey;

    private static final String URL =
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=";

    @Override
    public String chat(String prompt) {

        try {
            OkHttpClient client = new OkHttpClient();

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
                    .url(URL + apiKey)
                    .post(RequestBody.create(
                            body.toString(),
                            MediaType.parse("application/json")
                    ))
                    .build();

            Response response = client.newCall(request).execute();
            String json = response.body().string();

            JsonObject root = JsonParser.parseString(json).getAsJsonObject();

            return root
                    .getAsJsonArray("candidates")
                    .get(0).getAsJsonObject()
                    .getAsJsonObject("content")
                    .getAsJsonArray("parts")
                    .get(0).getAsJsonObject()
                    .get("text")
                    .getAsString();

        } catch (Exception e) {
            return "Gemini error: " + e.getMessage();
        }
    }
}