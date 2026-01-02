class MessageModel {
  final String id;
  final String sender;
  final String content;
  final DateTime time;
  final bool isRead;
  final String category;
  final int unreadCount;

  MessageModel({
    required this.id,
    required this.sender,
    required this.content,
    required this.time,
    this.isRead = false,
    required this.category,
    this.unreadCount = 0,
  });
}
