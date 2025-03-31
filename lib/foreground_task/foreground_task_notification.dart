import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:device_link/foreground_task/foreground_task_handler.dart';
import 'package:flutter/material.dart';

class ForegroundTaskNotification {

  void addTaskDataCallback() {
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  static void _onReceiveTaskData(Object data) {
    print('Received task data: $data');
  }

  static Future<void> _requestPermissions() async {
    final NotificationPermission notificationPermission =
    await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  Future<void> initService() async {
    await _requestPermissions();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Device Link Service',
        channelDescription: 'This notification appears when the foreground service is running.',
        onlyAlertOnce: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
      ),
    );
    print("Foreground service initialized");
  }

  Future<ServiceRequestResult> startService() async {
    print("Starting foreground service");
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 100,
        notificationTitle: 'Device Link',
        notificationText: 'Klepnutím otevřete aplikaci',
        notificationIcon: const NotificationIcon(
          metaDataName: 'com.device_link.service.NOTIFICATION_ICON_SERVICE_DEVICE_LINK',
        ),
        notificationInitialRoute: '/',
        callback: startTaskHandlerCallback,
      );
    }
  }
}