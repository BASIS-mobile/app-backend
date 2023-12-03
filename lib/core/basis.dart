import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:azlistview/azlistview.dart';
import 'package:flutter/services.dart';

import 'basis_backend.dart';
import 'data/storage.dart';

/// Function that returns a random user agent from a list of selected ones
String getRandomUserAgent() {
  const List<String> userAgents = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:57.0) Gecko/20100101 Firefox/100.0',
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/116.0"
  ];

  final Random random = Random();
  final String userAgent = userAgents[random.nextInt(userAgents.length)];

  return userAgent;
}

/// Class that handles the communication with the BASIS server
class Basis {
  final String host = "https://basis.uni-bonn.de/qisserver";
  Map<String, String> cookies = {};
  Map<String, String> headers = {"User-Agent": getRandomUserAgent()};

  final String loginPageParams = "?state=wlogin&login=in&breadCrumbSource=";
  final String loginPostParams =
      "?state=user&type=1&category=auth.login&re=last&startpage=portal.vm";

  /// Function that returns the data from a given file name
  Future<List<dynamic>> getData(
      {required final String fileName,
      required final String href,
      final List<String> excludeTitles = const [],
      final bool dedupe = true}) async {
    final http.Response urlContent =
        await fetchUrlContent(url: href); // Fetch BASIS html

    final Map<String, dynamic> fileContent =
        await SemesterStorage.getFile(fileName); // Get saved json selector file

    // Interpret the json selector file and parse the html
    List<dynamic> data = await interpretJson(fileContent, urlContent.bodyBytes,
        excludeTitles: excludeTitles, doRemoveDuplicates: dedupe);
    return data;
  }

  /// Funtion that returns all courses
  Future<List<dynamic>> getAlleVeranstaltungen(
      {String href = "", final List<String> excludeTitles = const []}) async {
    if (href.isEmpty) {
      // If no href is given, use the current semester
      href = await SemesterStorage.getCurrentSemesterHref();
    }

    return getData(
        fileName: "veranstaltungen", href: href, excludeTitles: excludeTitles);
  }

  /// Funtion that returns the headers of the table
  Future<List<dynamic>> getTabellenHeaders(
      {final String href = "",
      final List<String> excludeTitles = const []}) async {
    return getData(
        fileName: "termine_headers",
        href: href,
        excludeTitles: excludeTitles,
        dedupe: false);
  }

  /// Funtion that returns the contents of the table
  Future<List<dynamic>> getTabellenContent(
      {final String href = "",
      final List<String> excludeTitles = const []}) async {
    return getData(
        fileName: "termine_content",
        href: href,
        excludeTitles: excludeTitles,
        dedupe: false);
  }

  // Funtion that returns the list of semesters
  Future<List<dynamic>> getSemesterList() async {
    final String url = "$host/rds?state=user&type=0";

    final http.Response urlContent = await fetchUrlContent(url: url);

    final Map<String, dynamic> fileContent =
        await SemesterStorage.getFile("home");
    List<dynamic> data = await interpretJson(fileContent, urlContent.bodyBytes);

    return data;
  }

  void login(
      {required final String uniId, required final String password}) async {
    final String url = "$host/rds?";
    final Map<String, String> body = {
      "username": uniId,
      "password": password,
      "submit": "Anmelden"
    };
    final String cookieHeaderName = "Set-Cookie";

    Map<String, String> headers = {
      "Conten-Type": "application/x-www-form-urlencoded"
    };

    final http.Response urlContent = await fetchUrlContent(
        url: url + loginPostParams,
        requestBody: body,
        acceptHttpCode: 302,
        initialHeaders: headers);
    final Map<String, String> urlHeaders = urlContent.headers;

    if (urlHeaders.containsKey(cookieHeaderName)) {
      String loginCookie = urlHeaders[cookieHeaderName] ?? "";
      if (loginCookie.isEmpty) {
        throw HttpException("Cookie not found");
      }
      this.cookies = {"Cookies": loginCookie};
    }
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