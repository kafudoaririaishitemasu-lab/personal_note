import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  late final StreamSubscription _subscription;

  NetworkCubit() : super(NetworkInitial()) {
    _subscription = Connectivity().onConnectivityChanged.listen((_) {
      checkConnection();
    });
    checkConnection();
  }

  Future<bool> checkConnection() async {
    emit(NetworkLoading());
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      emit(NetworkDisconnected());
      return false;
    }
    else{
      try {
        final result = await InternetAddress.lookup('google.com');
        if(result.isNotEmpty && result[0].rawAddress.isNotEmpty){
          emit(NetworkConnected());
          return true;
        }else{
          emit(NetworkDisconnected());
          return false;
        }
      } catch (_) {
        emit(NetworkDisconnected());
        return false;
      }
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}

