import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestMediaPermission() async {
    try {
      if (await Permission.audio.isGranted) return true;
      var status = await Permission.audio.request();
      if (status.isGranted) return true;

      if (await Permission.storage.isGranted) return true;
      status = await Permission.storage.request();
      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }

  Future<bool> hasPermissions() async {
    try {
      return await Permission.audio.isGranted || await Permission.storage.isGranted;
    } catch (e) {
      debugPrint('Permission check error: $e');
      return false;
    }
  }
}
