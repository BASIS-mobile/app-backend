import 'dart:math';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'basis_backend.dart';
import 'storage.dart';

String getRandomUserAgent() {
  var userAgents = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:57.0) Gecko/20100101 Firefox/100.0',
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/116.0"
  ];

  var random = Random();
  var userAgent = userAgents[random.nextInt(userAgents.length)];

  return userAgent;
}

class Basis {
  String host = "https://basis.uni-bonn.de/qisserver";
  Map<String, String> cookies = {};
  Map<String, String> headers = {"User-Agent": getRandomUserAgent()};

  Future<List<dynamic>> getData(
      {required String fileName, required String href, List<String> excludeTitles = const [], bool dedupe = true}) async {
    final Uint8List urlContent = await fetchUrlContent(href);
    final Map<String, dynamic> fileContent =
        await SemesterStorage.getFile(fileName);
    List<dynamic> data = await interpretJson(fileContent, urlContent,
        excludeTitles: excludeTitles, doRemoveDuplicates: dedupe);
    return data;
  }

  Future<List<dynamic>> getAlleVeranstaltungen(
      {String href = "", List<String> excludeTitles = const []}) async {
    if (href.isEmpty) {
      href = await SemesterStorage.getCurrentSemesterHref();
    }

    return getData(
        fileName: "veranstaltungen", href: href, excludeTitles: excludeTitles);
  }

  Future<List<dynamic>> getTabellenHeaders(
      {String href = "", List<String> excludeTitles = const []}) async {
    return getData(fileName: "termine_headers", href: href, excludeTitles: excludeTitles, dedupe: false);
  }

  Future<List<dynamic>> getTabellenContent(
      {String href = "", List<String> excludeTitles = const []}) async {
    return getData(
        fileName: "termine_content", href: href, excludeTitles: excludeTitles, dedupe: false);
  }

  Future<List<dynamic>> getSemesterList() async {
    String url = "$host/rds?state=user&type=0";

    final Uint8List urlContent = await fetchUrlContent(url);

    final Map<String, dynamic> fileContent =
        await SemesterStorage.getFile("home");
    List<dynamic> data = await interpretJson(fileContent, urlContent);

    return data;
  }
}

class VorlesungenList extends ISuspensionBean {
  final String title;
  final String tag;
  final String href;

  VorlesungenList({required this.title, required this.tag, this.href = ""});

  @override
  String getSuspensionTag() {
    return tag;
  }
}
