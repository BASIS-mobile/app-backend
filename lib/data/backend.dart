import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'errors.dart';
import 'storage.dart';

Future<bool> isConnected() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi;
}

class Backend {
  String host = "<backend_host>";
  Map<String, String> headers = {"User-Agent": "<app_agent>"};

  Backend();

  Future<ErrorControl> checkVersions() async {
    bool success = false;
    String msg = "";
    int errorCode = Errors.UNEXPECTED_ERROR;

    if (!await isConnected()) {
      return ErrorControl(
          success: false,
          message: msg,
          errorCode: Errors.NETWORK_CONNECTION_ERROR);
    }

    try {
      var response =
          await http.get(Uri.parse("$host/versions"), headers: headers);

      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);

        String versionsKey = "versions";
        String warningsKey = "show_warnings";
        String msgKey = "messages";

        if (data.containsKey(versionsKey)) {
          List versions = data[versionsKey];

          List<dynamic> storedVersions = await SemesterStorage.getVersions();

          // Store the version on first app launch
          if (storedVersions.isEmpty) {
            await SemesterStorage.storeVersions(versions);
            storedVersions = versions;
            for (var v in storedVersions.indexed) {
              await fetchFile(v.$2["id"]);
            }
          } else {
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
      } else {
        success = false;
        errorCode = Errors.INVALID_API_RESPONSE;
      }
    } catch (_) {
      success = false;
      errorCode = Errors.SERVER_TIMEOUT;
    }

    if (!success) {
      this.reportErrorToEndpoint(
          className: (this).toString(), errorCode: errorCode, errorMsg: msg);
    }

    return ErrorControl(success: success, message: msg, errorCode: errorCode);
  }

  Future<void> fetchFile(String key) async {
    var response =
        await http.get(Uri.parse("$host/getfile/$key"), headers: headers);

    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      if (data.containsKey("identifiers")) {
        await SemesterStorage.storeFile(key, data["identifiers"]);
      }
    } else {
      Backend b = Backend();
      b.reportErrorToEndpoint(
          className: (this).toString(),
          errorCode: Errors.API_REQUEST_FAILED,
          errorMsg: "(${response.statusCode}) ${response.body}");
      throw Exception();
    }
  }

  Future<void> heartBeat() async {
    final String endpoint = '$host/heartbeat';
    bool isSentToday = await SemesterStorage.checkHeartBeatDate();
    if (!isSentToday) {
      try {
        await http.get(
          Uri.parse(endpoint),
        );
      } catch (e) {
        print('Failed to send heartbeat due to: $e');
      }
      SemesterStorage.storeLastHeartBeat();
    }
  }

  void reportErrorToEndpoint(
      {required int errorCode,
      required String errorMsg,
      required String className}) async {
    final String endpoint = '$host/reporterror';
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
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
