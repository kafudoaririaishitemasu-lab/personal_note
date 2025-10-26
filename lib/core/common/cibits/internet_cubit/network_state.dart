part of 'network_cubit.dart';

@immutable
sealed class NetworkState {}

final class NetworkInitial extends NetworkState {}

final class NetworkConnected extends NetworkState {}

final class NetworkDisconnected extends NetworkState {}

final class NetworkLoading extends NetworkState{}