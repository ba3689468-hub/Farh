import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseService {
  static const String projectId = 'farah-wedding-app';
  static const String apiKey = 'AIzaSyC3PhWGAAt7mHY4sJqorzPmCEqxJXwR5zQ';
  static const String _base =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  // ============ دوال عامة ============
  Future<List<Map<String, dynamic>>> _get(String col) async {
    try {
      final res = await http.get(Uri.parse('$_base/$col?key=$apiKey'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final docs = (data['documents'] as List?) ?? [];
        return docs.map((d) => _docToMap(d as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error get $col: $e');
    }
    return [];
  }

  Future<bool> _add(String col, Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/$col?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fields': _mapToFields(data)}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _update(String col, String id, Map<String, dynamic> data) async {
    try {
      final res = await http.patch(
        Uri.parse('$_base/$col/$id?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fields': _mapToFields(data)}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _delete(String col, String id) async {
    try {
      final res = await http.delete(Uri.parse('$_base/$col/$id?key=$apiKey'));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============ القاعات ============
  Future<List<Map<String, dynamic>>> getHalls() => _get('halls');
  Future<bool> addHall(Map<String, dynamic> h) => _add('halls', h);
  Future<bool> updateHall(String id, Map<String, dynamic> h) =>
      _update('halls', id, h);
  Future<bool> deleteHall(String id) => _delete('halls', id);

  // ============ أصحاب القاعات ============
  Future<List<Map<String, dynamic>>> getClients() => _get('clients');
  Future<Map<String, dynamic>?> findClientByPhone(String phone) async {
    final all = await getClients();
    try {
      return all.firstWhere((c) => c['phone'] == phone);
    } catch (_) {
      return null;
    }
  }

  Future<bool> addClient(Map<String, dynamic> c) => _add('clients', c);
  Future<bool> updateClient(String id, Map<String, dynamic> c) =>
      _update('clients', id, c);
  Future<bool> deleteClient(String id) => _delete('clients', id);

  // ============ الحجوزات ============
  Future<List<Map<String, dynamic>>> getBookings() => _get('bookings');
  Future<bool> addBooking(Map<String, dynamic> b) => _add('bookings', b);
  Future<bool> updateBooking(String id, Map<String, dynamic> b) =>
      _update('bookings', id, b);
  Future<bool> deleteBooking(String id) => _delete('bookings', id);

  // ============ Helpers ============
  Map<String, dynamic> _docToMap(Map<String, dynamic> doc) {
    final name = doc['name'] as String;
    final id = name.split('/').last;
    final fields = (doc['fields'] as Map<String, dynamic>?) ?? {};
    final result = <String, dynamic>{'id': id};
    fields.forEach((k, v) => result[k] = _parse(v as Map<String, dynamic>));
    return result;
  }

  dynamic _parse(Map<String, dynamic> v) {
    if (v.containsKey('stringValue')) return v['stringValue'];
    if (v.containsKey('integerValue')) {
      return int.tryParse(v['integerValue'].toString()) ?? 0;
    }
    if (v.containsKey('doubleValue')) {
      return (v['doubleValue'] as num).toDouble();
    }
    if (v.containsKey('booleanValue')) return v['booleanValue'];
    return null;
  }

  Map<String, dynamic> _mapToFields(Map<String, dynamic> map) {
    final f = <String, dynamic>{};
    map.forEach((k, v) {
      if (v is String) {
        f[k] = {'stringValue': v};
      } else if (v is int) {
        f[k] = {'integerValue': v.toString()};
      } else if (v is double) {
        f[k] = {'doubleValue': v};
      } else if (v is bool) {
        f[k] = {'booleanValue': v};
      }
    });
    return f;
  }
  
// ============ دوال عامة (جديدة) ============
Future<List<Map<String, dynamic>>> getCollection(String col) => _get(col);
Future<bool> addToCollection(String col, Map<String, dynamic> data) =>
    _add(col, data);
  
Future<bool> deleteCollectionItem(String col, String id) =>
    _delete(col, id);
}
