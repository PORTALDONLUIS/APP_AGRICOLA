import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/templates_repository.dart';
import '../../../core/network/http_error_handler.dart';

class TemplatesUiState {
  final String query;
  final bool syncing;
  final String? error;

  const TemplatesUiState({
    this.query = '',
    this.syncing = false,
    this.error,
  });

  TemplatesUiState copyWith({String? query, bool? syncing, String? error}) {
    return TemplatesUiState(
      query: query ?? this.query,
      syncing: syncing ?? this.syncing,
      error: error,
    );
  }
}

class TemplatesNotifier extends StateNotifier<TemplatesUiState> {
  TemplatesNotifier(this._repo) : super(const TemplatesUiState());

  final TemplatesRepository _repo;

  void setQuery(String v) => state = state.copyWith(query: v);

  Future<void> sync(int userId) async {
    try {
      state = state.copyWith(syncing: true, error: null);
      await _repo.syncAssigned(userId);
      state = state.copyWith(syncing: false);
    } catch (e, st) {
      state = state.copyWith(
        syncing: false,
        error: HttpErrorHandler.toUserMessage(e, st),
      );
    }
  }
}
