class NotificationModel {
  final int id;
  final String type;
  final String? entityType;
  final int? entityId;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String? createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    this.entityType,
    this.entityId,
    required this.title,
    required this.body,
    this.data,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is String) return int.tryParse(val);
      return null;
    }

    return NotificationModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      entityType: json['entity_type'] as String?,
      entityId: parseId(json['entity_id']),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
      createdAt: json['created_at'] as String?,
    );
  }
}
