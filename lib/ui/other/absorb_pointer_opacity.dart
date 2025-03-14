import 'package:device_link/notifiers/network_connectivity_status.dart';
import 'package:flutter/material.dart';
import 'package:device_link/notifiers/connection_manager.dart';
import 'package:device_link/ui/snackbars/error_snackbar.dart';

class AbsorbPointerOpacity extends StatefulWidget {
  final Widget child;
  final ConnectionManager connectionManager;
  final NetworkConnectivityStatus networkManager;


  const AbsorbPointerOpacity({
    super.key,
    required this.child,
    required this.connectionManager,
    required this.networkManager
  });

  @override
  State<AbsorbPointerOpacity> createState() => _AbsorbPointerOpacityState();
}

class _AbsorbPointerOpacityState extends State<AbsorbPointerOpacity> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.connectionManager, widget.networkManager]),
      builder: (BuildContext context, Widget? child) {
        return GestureDetector(
          onTap: () {
            if (widget.connectionManager.connectionIsActive || !widget.networkManager.isConnectedToNetwork) {
              String snackbarMsg = 'Nelze se připojit k jinému zařízení, ';
              if (widget.connectionManager.connectionIsActive) {
                snackbarMsg = '$snackbarMsg spojení je již aktivní';
              } else { //jina moznost nezbyva
                snackbarMsg = '$snackbarMsg vaše zařízení není připojeno k síti';
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: ErrorSnackBar(
                    message: snackbarMsg
                  ),
                  backgroundColor: Colors.transparent,
                  behavior: SnackBarBehavior.fixed,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else {
              return;
            }
          },
          child: Opacity(
            opacity: (widget.connectionManager.connectionIsActive || !widget.networkManager.isConnectedToNetwork) ? 0.5 : 1,
            child: AbsorbPointer(
              absorbing: (widget.connectionManager.connectionIsActive || !widget.networkManager.isConnectedToNetwork),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}