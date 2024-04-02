// overview_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'overview_event.dart';
import 'overview_state.dart';

class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  OverviewBloc() : super(OverviewInitial()) {
    on<LoadUnreadCount>(_onLoadUnreadCount);
  }

  Future<void> _onLoadUnreadCount(
      LoadUnreadCount event, Emitter<OverviewState> emit) async {
    emit(OverviewLoading());
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      int totalUnreadCount = 0;

      if (userId != null) {
        // Fetch user's chat IDs
        final chatRefs = await FirebaseFirestore.instance
            .collection('chats')
            .where('members', arrayContains: userId)
            .get();

        for (var doc in chatRefs.docs) {
          String chatId = doc.id;
          int unreadCount = await fetchUnreadCount(chatId, userId);
          totalUnreadCount += unreadCount;
        }
      }

      emit(OverviewLoaded(totalUnreadCount));
    } catch (e) {
      emit(OverviewError("Failed to load unread messages."));
    }
  }

  Future<int> fetchUnreadCount(String chatId, String userId) async {
    DocumentReference unreadCountRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('unreads')
        .doc(userId);

    try {
      DocumentSnapshot snapshot = await unreadCountRef.get();
      int unreadCount = snapshot.get('unreadCount');
      return unreadCount;
    } on StateError {
      // Field does not exist
      return 0;
    } catch (e) {
      // Handle any other errors
      print("Error fetching unread count: $e");
      return 0;
    }
  }
}
