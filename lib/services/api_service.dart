import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "143.198.118.203:8100";
  static const String _user = "test";
  static const String _pass = "test2023";

  static Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Authorization": "Basic ${base64Encode(utf8.encode("$_user:$_pass"))}",
  };

  static Uri _u(String path) => Uri.http(_baseUrl, path);

  static List<dynamic> _asList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final keys = ["data", "results", "items", "list"];
      for (final k in keys) {
        final v = decoded[k];
        if (v is List) return v;
      }
      for (final v in decoded.values) {
        if (v is List) return v;
      }
    }
    throw Exception("Formato inesperado de respuesta: $decoded");
  }

  //PRODUCTOS

  static Future<List<dynamic>> getProducts() async {
    final res = await http.get(
      _u("/ejemplos/product_list_rest/"),
      headers: headers,
    );
    if (res.statusCode != 200) {
      throw Exception("Error HTTP ${res.statusCode}: ${res.body}");
    }
    final decoded = jsonDecode(res.body);
    return _asList(decoded);
  }

  static Future<bool> addProduct(Map<String, dynamic> data) async {
    final res = await http.post(
      _u("/ejemplos/product_add_rest/"),
      headers: headers,
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  static Future<bool> editProduct(Map<String, dynamic> data) async {
    final res = await http.post(
      _u("/ejemplos/product_edit_rest/"),
      headers: headers,
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteProduct(int id) async {
    final res = await http.post(
      _u("/ejemplos/product_del_rest/"),
      headers: headers,
      body: jsonEncode({"product_id": id}),
    );
    return res.statusCode == 200;
  }

  //CATEGORÍAS

  static Future<List<dynamic>> getCategories() async {
    final res = await http.get(
      _u("/ejemplos/category_list_rest/"),
      headers: headers,
    );
    if (res.statusCode != 200) {
      throw Exception("Error HTTP ${res.statusCode}: ${res.body}");
    }
    final decoded = jsonDecode(res.body);
    return _asList(decoded);
  }

  static Future<bool> addCategory(Map<String, dynamic> data) async {
    final res = await http.post(
      _u("/ejemplos/category_add_rest/"),
      headers: headers,
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  static Future<bool> editCategory(Map<String, dynamic> data) async {
    final res = await http.post(
      _u("/ejemplos/category_edit_rest/"),
      headers: headers,
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteCategory(int id) async {
    final res = await http.post(
      _u("/ejemplos/category_del_rest/"),
      headers: headers,
      body: jsonEncode({"category_id": id}),
    );
    return res.statusCode == 200;
  }

  //PROVEEDORES

  static Future<List<dynamic>> getProviders() async {
    final res = await http.get(
      _u("/ejemplos/provider_list_rest/"),
      headers: headers,
    );
    if (res.statusCode != 200) {
      throw Exception("Error HTTP ${res.statusCode}: ${res.body}");
    }
    final decoded = jsonDecode(res.body);
    return _asList(decoded);
  }

  static Future<bool> addProvider(Map<String, dynamic> data) async {
    final res = await http.post(
      _u("/ejemplos/provider_add_rest/"),
      headers: headers,
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  static Future<bool> editProvider(Map<String, dynamic> data) async {
    final res = await http.post(
      _u("/ejemplos/provider_edit_rest/"),
      headers: headers,
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteProvider(int id) async {
    final res = await http.post(
      _u("/ejemplos/provider_del_rest/"),
      headers: headers,
      body: jsonEncode({"provider_id": id}),
    );
    return res.statusCode == 200;
  }
}
