class NotificationItem {

  final int id;
  final String title;
  final String message;
  final String date;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
  });

  factory NotificationItem.fromJson(Map<String,dynamic> json){

    return NotificationItem(
      id: json["id"],
      title: json["title"],
      message: json["message"],
      date: json["date"],
    );
  }
}