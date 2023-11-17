import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

/// Funtion to sanitize strings
String cleanString(String s) {
  s = s.replaceAll('\xa0', ' ');
  s = s.trim().split(RegExp(r'\s+')).join(' ');
  return s;
}

/// Funtion to get the wanted attributes of a given element
Map<String, dynamic> getAttributes(
    Map<String, dynamic> jsonData, Element element) {
  var entry = <String, dynamic>{};
  // Iterate over the wanted attributes
  for (var attr in jsonData['attributes']) {
    // If the attribute is content, get the text of the element
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

/// Funtion to fetch the html of a given url
Future<Uint8List> fetchUrlContent(String url) async {
  var headers = {HttpHeaders.userAgentHeader: "<user-agent>"};

  final http.Response response =
      await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode != 200) {
    throw HttpException('Request failed with status: ${response.statusCode}.');
  }
  return response.bodyBytes;
}

/// Funtion to interpret the json selector file and parse the html
Future<List> interpretJson(Map<String, dynamic> jsonData, List<int> urlContent,
    {List<String> excludeTitles = const [],
    bool doRemoveDuplicates = true}) async {
  // Get the wanted attributes from the json file
  bool removeDuplicates = jsonData['remove_duplicates'] ?? doRemoveDuplicates;
  String mainSelector = jsonData['selector'] ?? "";
  String childSelector = jsonData['child_selector'] ?? "";
  List grandchildSelectors = jsonData['grandchild_selectors'] ?? [];

  // Exclude the given titles from the results
  List<String> excludeFromResults = [];
  excludeFromResults.addAll(excludeTitles);
  excludeFromResults.add("Vorlesungsverzeichnis");

  // Parse the html
  Document document = html.parse(utf8.decode(urlContent));
  List mainElements = document.querySelectorAll(mainSelector);
  List extractedData = [];

  // Iterate over the main elements
  for (var mainElem in mainElements) {
    List data = [];
    // If there are grandchild selectors, get the attributes of the grandchildren
    if (grandchildSelectors.isNotEmpty) {
      // Iterate over the grandchild selectors
      for (var grandchildSelector in grandchildSelectors) {
        // Get the grandchildren
        List<Element> grandchildren =
            mainElem.querySelectorAll(grandchildSelector);

        List<Map<String, dynamic>> grandchildSubData = [];

        // Iterate over the found grandchildren
        for (var grandchild in grandchildren) {
          Map<String, dynamic> entry = getAttributes(jsonData, grandchild);
          // If the content of the grandchild is not in the exclude list, add it to the data
          if (!excludeFromResults.contains(entry["content"])) {
            grandchildSubData.add(entry);
          }
        }
        data.add(grandchildSubData); // Add the data to the main data
      }
      extractedData.add(data); // Add the main data to the extracted data

      // If there is a child selector, get the attributes of the children
    } else if (childSelector.isNotEmpty) {
      // Get the children
      List children = mainElem.querySelectorAll(childSelector);

      // Iterate over the found children
      for (var child in children) {
        Map<String, dynamic> entry = getAttributes(jsonData, child);
        // If the content of the child is not in the exclude list, add it to the data
        if (!excludeFromResults.contains(entry["content"])) {
          extractedData.add(entry);
        }
      }
    }
  }

  // Remove duplicates if wanted
  if (removeDuplicates) {
    var unique = <Map<String, dynamic>>[];
    var equality = const DeepCollectionEquality();

    // Iterate over the extracted data and remove duplicates
    for (var map in extractedData) {
      if (!unique.any((uniqueMap) => equality.equals(map, uniqueMap))) {
        unique.add(map);
      }
    }
    extractedData = unique;
  }

  return extractedData;
}
