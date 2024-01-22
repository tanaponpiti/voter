import 'package:fluttertoast/fluttertoast.dart';

class Toaster {
  static error(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
  }

  static log(String message) {
    Fluttertoast.showToast(msg: message);
  }
}
