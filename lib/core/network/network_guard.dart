import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/cibits/internet_cubit/network_cubit.dart';
import '../utils/snackbar.dart';

class NetworkGuard extends StatefulWidget {
  final Widget child;
  final VoidCallback callback;
  final Duration debounceDuration;

  const NetworkGuard({
    super.key,
    required this.child,
    required this.callback,
    this.debounceDuration = const Duration(seconds: 1),
  });

  @override
  State<NetworkGuard> createState() => _NetworkGuardState();
}

class _NetworkGuardState extends State<NetworkGuard> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NetworkCubit, NetworkState>(
      listener: (context, state) {
        if (state is NetworkDisconnected) {
          _debounceTimer?.cancel();
          UiSnack.showNetworkErrorSnackBar(context, isNetworkError: true);
        } else if (state is NetworkConnected) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(widget.debounceDuration, () {
            if (mounted) widget.callback();
          });
        }
      },
      builder: (context, state) {
        return widget.child;
      },
    );
  }
}
