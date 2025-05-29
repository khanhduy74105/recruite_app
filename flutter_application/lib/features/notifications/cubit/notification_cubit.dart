import 'package:bloc/bloc.dart';
import 'package:flutter_application/models/notification_model.dart';
import 'package:meta/meta.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  Future<void> loadNotifications(List<NotificationModel> listNotification) async {
    emit(NotificationLoading());
    try {
      await Future.delayed(const Duration(seconds: 2));
      emit(NotificationLoaded(listNotification));
    } catch (e) {
      emit(NotificationError('Failed to load notifications.'));
    }
  }

  void markAsRead(String notificationId) {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final updatedNotifications = currentState.notifications.map((notification) {
        if (notification.id == notificationId) {
          return NotificationModel(
            id: notification.id,
            createdAt: notification.createdAt,
            seen: true,
            type: notification.type,
            postId: notification.postId,
            relativeIds: notification.relativeIds,
          );
        }
        return notification;
      }).toList();
      emit(NotificationLoaded(updatedNotifications));
    }
  }

  void updateNotification(NotificationModel updatedNotification) {
    emit(NotificationUpdated(updatedNotification));
  }
}
