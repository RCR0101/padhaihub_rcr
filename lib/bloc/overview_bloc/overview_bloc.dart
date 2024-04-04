// overview_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
        final chatRefs =
            await FirebaseFirestore.instance.collection('chats').get();

        for (var chatDoc in chatRefs.docs) {
          final chatId = chatDoc.id;
          final unreadsSnapshot = await FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .collection('unreads')
              .doc(userId)
              .get();

          final unreadCount = unreadsSnapshot.exists
              ? (unreadsSnapshot['unreadCount'] ?? 0)
              : 0; // If unreadsSnapshot doesn't exist, unreadCount is 0
          totalUnreadCount += unreadCount as int;
        }
      }

      emit(OverviewLoaded(totalUnreadCount));
    } catch (e, stackTrace) {
      Fluttertoast.showToast(msg: "Error loading unread count: $e");
      Fluttertoast.showToast(msg: "Stack trace: $stackTrace");
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
      DocumentSnapshot snapshot =
          await unreadCountRef.get(GetOptions(source: Source.server));
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
