import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startTaskHandlerCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) {
    // TODO: implement onStart
    throw UnimplementedError();
  }

  @override
  void onNotificationButtonPressed(String id) async {
    print('onNotificationButtonPressed: $id');
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    // TODO: implement onRepeatEvent
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // TODO: implement onDestroy
    throw UnimplementedError();
  }
}