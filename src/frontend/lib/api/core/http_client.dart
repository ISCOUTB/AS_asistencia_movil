  import 'dart:convert';
  import 'package:http/http.dart' as http;

  /// Wrapper universal de respuesta
  class HttpResponse {
    final int statusCode;
    final String body;
    final Map<String, String> headers;

    HttpResponse({
      required this.statusCode,
      required this.body,
      required this.headers,
    });
  }

  /// Cliente HTTP unificado para toda la app
  class HttpClient {
    final String baseUrl;

    /// Headers globales
    final Map<String, String> _headers = {
      'Accept': 'application/json',
      'User-Agent': 'Flutter-Client',
    };

    /// Cookies compartidas
    final Map<String, String> _cookies = {};

    HttpClient(this.baseUrl);

    // -------------------------------------------------------------
    // Helpers internos
    // -------------------------------------------------------------

    /// Inserta las cookies actuales en los headers
    void _applyCookies() {
      if (_cookies.isNotEmpty) {
        _headers['cookie'] = _cookies.entries
            .map((e) => '${e.key}=${e.value}')
            .join('; ');
      }
    }

    /// Lee cookies nuevas del servidor
    void _updateCookies(http.Response response) {
      final rawCookies = response.headers['set-cookie'];
      if (rawCookies != null) {
        // Tomamos solo el primer parámetro antes del ';'
        final cookie = rawCookies.split(';')[0];
        final parts = cookie.split('=');
        if (parts.length == 2) {
          _cookies[parts[0]] = parts[1];
        }
      }
    }

    /// Convierte un mapa de query a string JSON para ?q={}
    Map<String, String> _encodeQuery(Map<String, dynamic>? query) {
      if (query == null) return {};
      return query.map((key, value) => MapEntry(
            key,
            jsonEncode(value),
          ));
    }

    /// Construye el URL completo
    Uri _buildUri(String path, Map<String, dynamic>? query) {
      return Uri.parse(baseUrl + path)
          .replace(queryParameters: _encodeQuery(query));
    }

    // -------------------------------------------------------------
    // Métodos públicos GET / POST / PUT / DELETE
    // -------------------------------------------------------------

    Future<HttpResponse> get(String path, {Map<String, dynamic>? query}) async {
      _applyCookies();

      final uri = _buildUri(path, query);
      final resp = await http.get(uri, headers: _headers);

      _updateCookies(resp);

      return HttpResponse(
        statusCode: resp.statusCode,
        body: resp.body,
        headers: resp.headers,
      );
    }

    Future<HttpResponse> post(String path, Map<String, dynamic> body,
        {Map<String, dynamic>? query}) async {
      _applyCookies();

      final uri = _buildUri(path, query);
      final resp = await http.post(
        uri,
        headers: {
          ..._headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      _updateCookies(resp);

      return HttpResponse(
        statusCode: resp.statusCode,
        body: resp.body,
        headers: resp.headers,
      );
    }

    Future<HttpResponse> put(String path, Map<String, dynamic> body,
        {Map<String, dynamic>? query}) async {
      _applyCookies();

      final uri = _buildUri(path, query);
      final resp = await http.put(
        uri,
        headers: {
          ..._headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      _updateCookies(resp);

      return HttpResponse(
        statusCode: resp.statusCode,
        body: resp.body,
        headers: resp.headers,
      );
    }

    Future<HttpResponse> delete(String path, {Map<String, dynamic>? query}) async {
      _applyCookies();

      final uri = _buildUri(path, query);
      final resp = await http.delete(uri, headers: _headers);

      _updateCookies(resp);

      return HttpResponse(
        statusCode: resp.statusCode,
        body: resp.body,
        headers: resp.headers,
      );
    }
  }
