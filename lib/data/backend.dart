import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'errors.dart';
import 'storage.dart';

/// Function that checks if the device is connected to the internet
Future<bool> isConnected() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi;
}

/// Class that handles the communication with the backend server
class Backend {
  String host = "<backend_host>";
  Map<String, String> headers = {"User-Agent": "<app_agent>"};

  Backend();

  /// Function that checks if the app's selector files are up to date
  Future<ErrorControl> checkVersions() async {
    bool success = false;
    String msg = "";
    int errorCode = Errors.UNEXPECTED_ERROR;

    // If the device is not connected to the internet, return NetworkConnectionError
    if (!await isConnected()) {
      return ErrorControl(
          success: false,
          message: msg,
          errorCode: Errors.NETWORK_CONNECTION_ERROR);
    }

    try {
      // Get the versions from the backend
      http.Response response =
          await http.get(Uri.parse("$host/versions"), headers: headers);

      // If the response is successful, check if the versions are up to date
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);

        final String versionsKey = "versions";
        final String warningsKey = "show_warnings";
        final String msgKey = "messages";

        if (data.containsKey(versionsKey)) {
          List versions = data[versionsKey];

          // Get the stored versions
          List<dynamic> storedVersions = await SemesterStorage.getVersions();

          // If storedVersions is empty, store the version (first app launch)
          if (storedVersions.isEmpty) {
            await SemesterStorage.storeVersions(versions);
            storedVersions = versions;

            // Iterate over the versions and fetch the files
            for (var v in storedVersions.indexed) {
              await fetchFile(v.$2["id"]);
            }
          } else {
            // Iterate over the versions and fetch the files if the version is newer
            for (var v in storedVersions.indexed) {
              if (versions[v.$1]["version_number"] > v.$2["version_number"]) {
                await fetchFile(v.$2["id"]);
              }
            }
          }
          success = true;
        } else if (data.containsKey(warningsKey) && data.containsKey(msgKey)) {
          // Decode msg String to show special characters like "ö", "ü" or "ä"
          msg = utf8.decode(data[msgKey][0].codeUnits);
          errorCode = Errors.SERVER_MANUAL_WARNING;
        }
        // If the response is not successful, return InvalidApiResponse
      } else {
        success = false;
        errorCode = Errors.INVALID_API_RESPONSE;
      }
    } catch (_) {
      success = false;
      errorCode = Errors.SERVER_TIMEOUT;
    }

    // If the version check was not successful, report the error to the backend
    if (!success) {
      this.reportErrorToEndpoint(
          className: (this).toString(), errorCode: errorCode, errorMsg: msg);
    }

    return ErrorControl(success: success, message: msg, errorCode: errorCode);
  }

  /// Function that fetches the selector file (corresponding to the given key) from the backend
  Future<void> fetchFile(String key) async {
    // Get the file from the backend
    http.Response response =
        await http.get(Uri.parse("$host/getfile/$key"), headers: headers);

    final String identifiersKey = "identifiers";

    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);

      // If the file contains identifiers, store them
      if (data.containsKey(identifiersKey)) {
        await SemesterStorage.storeFile(key, data[identifiersKey]);
      }

    // If the response is not successful, report the error to the backend
    } else {
      this.reportErrorToEndpoint(
          className: (this).toString(),
          errorCode: Errors.API_REQUEST_FAILED,
          errorMsg: "(${response.statusCode}) ${response.body}");
      throw Exception();
    }
  }

  /// Function that sends a heartbeat to the backend.
  /// The heartbeat is sent once a day, if the app is opened.
  Future<void> heartBeat() async {
    final String endpoint = '$host/heartbeat';
    // Check if the heartbeat was already sent today
    bool isSentToday = await SemesterStorage.checkHeartBeatDate();

    if (!isSentToday) {
      try {
        await http.get(
          Uri.parse(endpoint),
        );
      } catch (e) {
        //print('Failed to send heartbeat due to: $e');
      }
      SemesterStorage.storeLastHeartBeat();
    }
  }

  /// Function that sends an error report to the backend
  void reportErrorToEndpoint(
      {required int errorCode,
      required String errorMsg,
      required String className}) async {
    final String endpoint = '$host/reporterror';

    // Get the app version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // Prepare the request body
    final Map<String, dynamic> payload = {
      'error_code': errorCode,
      'content': {
        "class": className,
        "msg": errorMsg,
      },
      'version': packageInfo.version
    };

    try {
      await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
    } catch (e) {
      //print('Failed to send error report due to: $e');
    }
  }
}

/// Class that represents an error
class ErrorControl {
  const ErrorControl(
      {required this.success,
      this.errorCode = Errors.UNEXPECTED_ERROR,
      this.message =
          "Ein unerwarteter Fehler ist aufgetreten. Bitte starten Sie die App neu."});

  final bool success;
  final String message;
  final int errorCode;
}
