class NotificationItem {
  final int    id;
  final String title;
  final String message;
  final String category;
  final bool   isRead;
  final String createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id:        json["id"]         ?? 0,
      title:     json["title"]      ?? "",
      message:   json["message"]    ?? "",
      category:  json["category"]   ?? "system",
      isRead:    json["is_read"]    ?? false,
      createdAt: json["created_at"] ?? "",
    );
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id:        id,
      title:     title,
      message:   message,
      category:  category,
      isRead:    isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}