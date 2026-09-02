import 'package:equatable/equatable.dart';

enum ConcreteState {
  initial,
  loading,
  loaded,
  failure,
  fetchingMore,
  fetchedAllProducts,
}

class BaseState<T> extends Equatable {
  final T? data;
  final bool isLoading;
  final String message;
  final ConcreteState state;

  const BaseState({
    this.data,
    this.isLoading = false,
    this.message = '',
    this.state = ConcreteState.initial,
  });

  BaseState<T> copyWith({
    T? data,
    bool? isLoading,
    String? message,
    ConcreteState? state,
  }) {
    return BaseState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      state: state ?? this.state,
    );
  }

  @override
  List<Object?> get props => [data, isLoading, message, state];
}
