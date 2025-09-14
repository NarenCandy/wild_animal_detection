class Alert {
  final String id;
  final String animal;
  final String imageUrl;
  final String timestamp;

  Alert(
      {required this.id,
      required this.animal,
      required this.imageUrl,
      required this.timestamp});

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'],
      animal: json['animal'],
      imageUrl: json['image_url'] ?? '',
      timestamp: json['timestamp'],
    );
  }
}
