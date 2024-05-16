import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

Future<http.Response> getLocationData(String text) async {
  http.Response response;
  response = await http
      .get(Uri.parse(''), headers: {"Content-Type": "application/json"});
  log(jsonDecode(response.body));
  return response;
}
