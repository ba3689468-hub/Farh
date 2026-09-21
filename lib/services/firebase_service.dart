import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseService {
  static const String projectId = 'farah-wedding-app';
  static const String apiKey = 'AIzaSyC3PhWGAAt7mHY4sJqorzPmCEqxJXwR5zQ';
  static const String _base =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  // ============ القاعات ============
  Future<List<Map<String, dynamic>>> getHalls() async {
    try {
      final res = await http.get(Uri.parse('$_base/halls?key=$apiKey'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final docs = (data['documents'] as List?) ?? [];
        return docs.map((d) => _docToMap(d as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error getHalls: $e');
    }
    return [];
  }

  Future<bool> addHall(Map<String, dynamic> hall) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/halls?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fields': _mapToFields(hall)}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateHall(String id, Map<String, dynamic> hall) async {
    try {
      final res = await http.patch(
        Uri.parse('$_base/halls/$id?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fields': _mapToFields(hall)}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteHall(String id) async {
    try {
      final res = await http.delete(Uri.parse('$_base/halls/$id?key=$apiKey'));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============ الحجوزات ============
  Future<List<Map<String, dynamic>>> getBookings() async {
    try {
      final res = await http.get(Uri.parse('$_base/bookings?key=$apiKey'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final docs = (data['documents'] as List?) ?? [];
        return docs.map((d) => _docToMap(d as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error getBookings: $e');
    }
    return [];
  }

  Future<bool> addBooking(Map<String, dynamic> booking) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/bookings?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fields': _mapToFields(booking)}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBooking(String id, Map<String, dynamic> booking) async {
    try {
      final res = await http.patch(
        Uri.parse('$_base/bookings/$id?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fields': _mapToFields(booking)}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBooking(String id) async {
    try {
      final res = await http.delete(Uri.parse('$_base/bookings/$id?key=$apiKey'));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============ Helpers ============
  Map<String, dynamic> _docToMap(Map<String, dynamic> doc) {
    final name = doc['name'] as String;
    final id = name.split('/').last;
    final fields = (doc['fields'] as Map<String, dynamic>?) ?? {};
    final result = <String, dynamic>{'id': id};
    fields.forEach((k, v) {
      result[k] = _parseValue(v as Map<String, dynamic>);
    });
    return result;
  }

  dynamic _parseValue(Map<String, dynamic> value) {
    if (value.containsKey('stringValue')) return value['stringValue'];
    if (value.containsKey('integerValue')) {
      return int.tryParse(value['integerValue'].toString()) ?? 0;
    }
    if (value.containsKey('doubleValue')) {
      return (value['doubleValue'] as num).toDouble();
    }
    if (value.containsKey('booleanValue')) return value['booleanValue'];
    return null;
  }

  Map<String, dynamic> _mapToFields(Map<String, dynamic> map) {
    final fields = <String, dynamic>{};
    map.forEach((k, v) {
      if (v is String) {
        fields[k] = {'stringValue': v};
      } else if (v is int) {
        fields[k] = {'integerValue': v.toString()};
      } else if (v is double) {
        fields[k] = {'doubleValue': v};
      } else if (v is bool) {
        fields[k] = {'booleanValue': v};
      }
    });
    return fields;
  }
}
