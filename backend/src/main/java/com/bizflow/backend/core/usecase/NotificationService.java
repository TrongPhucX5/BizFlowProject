package com.bizflow.backend.core.usecase;

public interface NotificationService {
    
    /**
     * Send notification to a specific device
     * 
     * @param token FCM Device Token
     * @param title Notification Title
     * @param body Notification Body
     */
    void sendNotification(String token, String title, String body);

    /**
     * Send notification to a topic (e.g., "store_1_orders")
     * 
     * @param topic Topic name
     * @param title Notification Title
     * @param body Notification Body
     */
    void sendTopicNotification(String topic, String title, String body);
}
