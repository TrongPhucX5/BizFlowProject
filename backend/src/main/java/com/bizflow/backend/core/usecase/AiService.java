package com.bizflow.backend.core.usecase;

import java.util.Map;

public interface AiService {
    Map<String, Object> analyzeText(String text, String intent);
}
