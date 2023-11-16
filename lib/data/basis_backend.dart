import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

String cleanString(String s) {
  s = s.replaceAll('\xa0', ' ');
  s = s.trim().split(RegExp(r'\s+')).join(' ');
  return s;
}

Map<String, dynamic> getAttributes(
    Map<String, dynamic> jsonData, Element element) {
  var entry = <String, dynamic>{};
  for (var attr in jsonData['attributes']) {
    if (attr == 'content') {
      String value = cleanString(element.text.trim());

      entry[attr] = value;
    } else {
      var value = element.attributes[attr] ?? "";
      entry[attr] = value;
    }
  }
  return entry;
}

Future<Uint8List> fetchUrlContent(String url) async {
  var headers = {HttpHeaders.userAgentHeader: "<user-agent>"};

  var response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode != 200) {
    throw HttpException('Request failed with status: ${response.statusCode}.');
  }
  return response.bodyBytes;
}

Future<List> interpretJson(Map<String, dynamic> jsonData, List<int> urlContent,
    {List<String> excludeTitles = const [],
    bool doRemoveDuplicates = true}) async {
  bool removeDuplicates = jsonData['remove_duplicates'] ?? doRemoveDuplicates;
  String mainSelector = jsonData['selector'] ?? "";
  String childSelector = jsonData['child_selector'] ?? "";
  List grandchildSelectors = jsonData['grandchild_selectors'] ?? [];

  List<String> excludeFromResults = [];
  excludeFromResults.addAll(excludeTitles);
  excludeFromResults.add("Vorlesungsverzeichnis");

  Document document = html.parse(utf8.decode(urlContent));
  List mainElements = document.querySelectorAll(mainSelector);
  List extractedData = [];

  for (var mainElem in mainElements) {
    List data = [];
    if (grandchildSelectors.isNotEmpty) {
      for (var grandchildSelector in grandchildSelectors) {
        List<Element> grandchildren =
            mainElem.querySelectorAll(grandchildSelector);
        List<Map<String, dynamic>> grandchildSubData = [];
        for (var grandchild in grandchildren) {
          Map<String, dynamic> entry = getAttributes(jsonData, grandchild);
          if (!excludeFromResults.contains(entry["content"])) {
            grandchildSubData.add(entry);
          }
        }
        data.add(grandchildSubData);
      }
      extractedData.add(data);
    } else if (childSelector.isNotEmpty) {
      List children = mainElem.querySelectorAll(childSelector);
      for (var child in children) {
        Map<String, dynamic> entry = getAttributes(jsonData, child);
        if (!excludeFromResults.contains(entry["content"])) {
          extractedData.add(entry);
        }
      }
    }
  }

  if (removeDuplicates) {
    var unique = <Map<String, dynamic>>[];
    var equality = const DeepCollectionEquality();

    for (var map in extractedData) {
      if (!unique.any((uniqueMap) => equality.equals(map, uniqueMap))) {
        unique.add(map);
      }
    }
    extractedData = unique;
  }

  return extractedData;
}
