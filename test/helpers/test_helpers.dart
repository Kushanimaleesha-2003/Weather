import 'package:hive/hive.dart';

/// Helper function to create an in-memory Hive box for testing
Future<Box> createTestBox() async {
  Hive.init('test');
  return await Hive.openBox('test_box');
}

/// Helper function to clear test box
Future<void> clearTestBox(Box box) async {
  await box.clear();
  await box.close();
}

