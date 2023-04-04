import 'dart:io' as fs;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission(Permission permission) async {
  if (await permission.isGranted) {
    return true;
  } else {
    var result = await permission.request();
    return (result == PermissionStatus.granted);
    }
}

Future<bool> saveImage(ByteData imgBytes) async {
  if (await requestPermission(Permission.manageExternalStorage)) {
    fs.Directory? directory = await getExternalStorageDirectory();
    if (directory == null) return false;
    String newPath = "";
    List<String> paths = directory.path.split("/");
    for (int x = 1; x < paths.length; x++) {
      String folder = paths[x];
      if (folder != "Android") {
        newPath += "/$folder";
      } else {
        break;
      }
    }
    newPath += "/DrawBoard";
    directory = fs.Directory(newPath);
    directory.create(recursive: true);
    fs.File('$newPath/savedImage.png').writeAsBytesSync(imgBytes.buffer.asInt8List());
    return true;
  }
  return false;
}
