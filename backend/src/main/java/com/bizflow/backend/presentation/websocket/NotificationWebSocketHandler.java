package com.bizflow.backend.presentation.websocket;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Component
public class NotificationWebSocketHandler extends TextWebSocketHandler {

    // Store sessions mapped by Store ID (extracted from query param or header)
    // For simplicity, we just store all sessions for now, or map session -> storeId
    private final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        // Extract storeId if needed, for now just add
        sessions.put(session.getId(), session);
        log.info("WebSocket connected: {}", session.getId());
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        sessions.remove(session.getId());
        log.info("WebSocket disconnected: {}", session.getId());
    }

    public void broadcast(String message) {
        sessions.values().forEach(session -> {
            try {
                if (session.isOpen()) {
                    session.sendMessage(new TextMessage(message));
                }
            } catch (IOException e) {
                log.error("Error sending WebSocket message", e);
            }
        });
    }

    // Send to specific store topic (client should filter, or we filter here if we
    // tracked storeId)
    // For this demo 'Ting ting', broadcast is fine, or we can improve filtering
    // later.
    public void sendToStore(Long storeId, String message) {
        // In a real app, track session's storeId. Here we broadcast to all for "demo
        // effect"
        // or assuming single store per client context for now.
        broadcast(message);
    }
}
