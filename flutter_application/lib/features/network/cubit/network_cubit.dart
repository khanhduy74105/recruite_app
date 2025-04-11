import 'package:bloc/bloc.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/features/auth/repository/auth_repository.dart';
import 'package:flutter_application/features/network/repository/network_repository.dart';
import 'package:flutter_application/models/user_connection.dart';
import 'package:flutter_application/models/user_models.dart';
import 'package:meta/meta.dart';

part 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit() : super(NetworkInitial());

  void getUsers() async {
    emit(NetworkLoading());
    try {
      List<UserModel> usersNotFriends =
          await AuthRepository().getUsersNotFriend();
      List<UserConnection> connections = await NetworkRepository()
          .fetchConnections(SupabaseService.getCurrentUserId());
      List<UserModel> usersFriends = await AuthRepository().getFriends();
      emit(NetworkLoaded(usersNotFriends, connections, usersFriends));
    } catch (e) {
      emit(NetworkError(e.toString()));
    }
  }

  void sendConnectionRequest(String friendId) async {
    try {
      await NetworkRepository().createConnection(
        SupabaseService.getCurrentUserId(),
        friendId
      );
      getUsers();
    } catch (e) {
      print('Error sending connection request: $e');
      emit(NetworkError(e.toString()));
    }
  }

  void acceptConnectionRequest(UserConnection connection) async {
    try {
      await NetworkRepository().updateConnection(
        connection,
        ConnectionStatus.accepted
      );
      getUsers();
    } catch (e) {
      emit(NetworkError(e.toString()));
    }
  }

  void rejectConnectionRequest(UserConnection connection) async {
    try {
      await NetworkRepository().updateConnection(
        connection,
        ConnectionStatus.declined
      );
      getUsers();
    } catch (e) {
      emit(NetworkError(e.toString()));
    }
  }
}
