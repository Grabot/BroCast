import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> initializeDirectories() async {
  final directory = await getApplicationDocumentsDirectory();
  final imageDirectory = Directory('${directory.path}/images');
  final videosDirectory = Directory('${directory.path}/videos');
  final audioDirectory = Directory('${directory.path}/audio');
  if (!await imageDirectory.exists()) {
    await imageDirectory.create(recursive: true);
  }
  if (!await videosDirectory.exists()) {
    await videosDirectory.create(recursive: true);
  }
  if (!await audioDirectory.exists()) {
    await audioDirectory.create(recursive: true);
  }
}