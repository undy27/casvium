import 'dart:convert';

import 'package:http/http.dart' as http;

import 'local_household_storage.dart';

const configuredRailwayDatabaseUrl = '';

Future<HouseholdSnapshot?> loadRailwayHousehold(
  String accessKey,
  String householdId,
) async {
  final uri = Uri.base.resolve('/api/household').replace(
    queryParameters: {'id': householdId},
  );
  final response = await http.get(uri, headers: {
    'Authorization': 'Bearer $accessKey',
  }).timeout(const Duration(seconds: 15));
  final data = _readResponse(response);
  final snapshot = data['snapshot'];
  return snapshot == null
      ? null
      : HouseholdSnapshot.decode(jsonEncode(snapshot));
}

Future<void> saveRailwayHousehold(
  String accessKey,
  HouseholdSnapshot snapshot,
) async {
  final response = await http
      .post(
        Uri.base.resolve('/api/sync'),
        headers: {
          'Authorization': 'Bearer $accessKey',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: snapshot.encode(),
      )
      .timeout(const Duration(seconds: 15));
  _readResponse(response);
}

Map<String, dynamic> _readResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map<String, dynamic> && data['ok'] == true) return data;
      break;
    case 401:
      throw const FormatException(
          'La clave de acceso de Railway no es válida.');
    case 503:
      throw const FormatException(
          'La conexión a Railway todavía no está configurada en el servidor.');
  }
  throw StateError('Railway HTTP ${response.statusCode}');
}
