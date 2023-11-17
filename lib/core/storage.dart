import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class SemesterStorage {
  static const String _CURRENT_SEMESTER_KEY = 'currentSemesterHref';
  static const String _VERSIONS_KEY = 'versions';
  static const String _FAV_VERANSTALTUNGEN_KEY = 'favs';
  static const String _HEART_BEAT_KEY = 'heartbeat';
  static const String heartBeatDateFormat = 'yyyy-MM-dd hh:mm:ss';
  static const _storage = FlutterSecureStorage();

  // Store the currently selected semester's href
  static Future<void> storeCurrentSemesterHref(String href) async {
    await _storage.write(key: _CURRENT_SEMESTER_KEY, value: href);
  }

  // Store file versions
  static Future<void> storeVersions(List<dynamic> data) async {
    await _storage.write(key: _VERSIONS_KEY, value: jsonEncode(data));
  }

  // Store file versions
  static Future<void> storeFile(String key, Map<String, dynamic> data) async {
    await _storage.write(key: "file_$key", value: jsonEncode(data));
  }

  // Store last Heart Beat Date
  static Future<void> storeLastHeartBeat() async {
    var now = DateTime.now();
    String dateTimeString = DateFormat(heartBeatDateFormat).format(now);
    await _storage.write(key: _HEART_BEAT_KEY, value: dateTimeString);
  }

  // Retrieve Heart Beat Date
  static Future<bool> checkHeartBeatDate() async {
    String dateTimeString = await _storage.read(key: _HEART_BEAT_KEY) ?? "";
    if (dateTimeString.isEmpty) return false;
    DateTime dateTime = DateFormat(heartBeatDateFormat).parse(dateTimeString);
    DateTime twentyFourHoursAgo =
        DateTime.now().subtract(const Duration(hours: 24));

    return !dateTime.isBefore(twentyFourHoursAgo);
  }

  // Store Fav Veranstaltungen
  static Future<void> storeFavVeranstaltung(
      String studiengang, String veranstaltung) async {
    Map data = await getFavVeranstaltungen();
    List veranstaltungen = [];
    if (data.containsKey(studiengang)) {
      veranstaltungen = data[studiengang];
    }
    if (veranstaltung.isNotEmpty) {
      veranstaltungen.add(veranstaltung);
    }
    data[studiengang] = veranstaltungen;
    await _storage.write(
        key: _FAV_VERANSTALTUNGEN_KEY, value: jsonEncode(data));
  }

  // Remove from Fav Veranstaltungen List
  static Future<void> removeFavVeranstaltung(
      String studiengang, String veranstaltung,
      {bool deleteGroup = false}) async {
    Map data = await getFavVeranstaltungen();
    List veranstaltungen = data[studiengang] ?? [];
    if (deleteGroup) {
      data.remove(studiengang);
    } else {
      veranstaltungen.remove(veranstaltung);
      data[studiengang] = veranstaltungen;
    }
    await _storage.write(
        key: _FAV_VERANSTALTUNGEN_KEY, value: jsonEncode(data));
  }

  // Retrieve Fav Veranstaltungen
  static Future<Map> getFavVeranstaltungen() async {
    return jsonDecode(
        await _storage.read(key: _FAV_VERANSTALTUNGEN_KEY) ?? "{}");
  }

  // Delete Fav Veranstaltungen
  static Future<void> deleteFavVeranstaltungen() async {
    await _storage.delete(key: _FAV_VERANSTALTUNGEN_KEY);
  }

  // Retrieve files
  static Future<Map<String, dynamic>> getFile(String key) async {
    //print("file_$key");
    return jsonDecode(await _storage.read(key: "file_$key") ?? "{}");
  }

  // Retrieve file versions
  static Future<List<dynamic>> getVersions() async {
    return jsonDecode(await _storage.read(key: _VERSIONS_KEY) ?? "[]");
  }

  // Retrieve the currently selected semester's href
  static Future<String> getCurrentSemesterHref() async {
    return await _storage.read(key: _CURRENT_SEMESTER_KEY) ?? "";
  }
}
