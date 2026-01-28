package com.bizflow.backend.core.usecase.impl;

import com.bizflow.backend.core.usecase.NotificationService;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@lombok.RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final com.bizflow.backend.presentation.websocket.NotificationWebSocketHandler webSocketHandler;

    @Override
    public void sendNotification(String token, String title, String body) {
        try {
            Message message = Message.builder()
                    .setToken(token)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            log.info("Successfully sent message: {}", response);
        } catch (Exception e) {
            log.error("Error sending FCM notification", e);
        }
    }

    @Override
    public void sendTopicNotification(String topic, String title, String body) {
        sendTopicNotification(topic, title, body, null);
    }

    @Override
    public void sendTopicNotification(String topic, String title, String body, Long orderId) {
        // Send WebSocket Notification
        try {
            String jsonMessage = String.format("{\"topic\":\"%s\",\"title\":\"%s\",\"body\":\"%s\",\"orderId\":\"%s\"}",
                    topic, title, body, orderId != null ? orderId : "");
            webSocketHandler.broadcast(jsonMessage);
        } catch (Exception e) {
            log.error("Error sending WebSocket notification", e);
        }

        try {
            Message.Builder messageBuilder = Message.builder()
                    .setTopic(topic)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build());

            if (orderId != null) {
                messageBuilder.putData("orderId", String.valueOf(orderId));
            }

            String response = FirebaseMessaging.getInstance().send(messageBuilder.build());
            log.info("Successfully sent topic message: {}", response);
        } catch (Exception e) {
            log.error("Error sending FCM topic notification", e);
        }
    }
}
