import '../../../../core/api/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<List<NotificationModel>> fetchNotifications({int page = 1}) async {
    final response = await _apiClient.get(
      '/api/notifications',
      queryParameters: {'page': page},
    );

    List rawData = [];
    if (response.data is Map<String, dynamic>) {
      final dataField = response.data['data'];
      if (dataField is List) {
        rawData = dataField;
      }
    } else if (response.data is List) {
      rawData = response.data as List;
    }

    return rawData
        .whereType<Map<String, dynamic>>()
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }

  Future<void> deleteNotification(int id) async {
    await _apiClient.delete('/api/notifications/$id');
  }
}
