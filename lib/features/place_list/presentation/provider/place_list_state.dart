import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class PlaceListState extends Equatable {
  final bool isLoading;
  const PlaceListState({required this.isLoading});
  const PlaceListState.initial({
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [isLoading];
  @override
  bool get stringify => true;
  PlaceListState copyWith({bool? isLoading}) {
    return PlaceListState(isLoading: isLoading ?? this.isLoading);
  }
}
