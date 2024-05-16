import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class SearchLocationState extends Equatable {
  final bool isLoading;

  const SearchLocationState({
    required this.isLoading,
  });

  const SearchLocationState.initial({
    this.isLoading = false,
  });

  @override
  List<Object> get props => [
        isLoading,
      ];

  @override
  bool get stringify => true;

  SearchLocationState copyWith({
    bool? isLoading,
  }) {
    return SearchLocationState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
