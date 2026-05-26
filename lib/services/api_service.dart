import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class LoginResult {
  final bool success;
  final String status;
  final User? user;

  LoginResult({
    required this.success,
    required this.status,
    this.user,
  });
}

class ApiService {
  static const String baseUrl = 'https://jobinja.ir/login/user';

  Future<LoginResult> login(String email, String password) async {
    const loginUrl = 'https://jobinja.ir/login/user';

    final client = HttpClient();
    final cookies = <Cookie>[];

    try {
      final getRequest = await client.getUrl(Uri.parse(loginUrl));
      _addBrowserHeaders(getRequest);

      final getResponse = await getRequest.close();

      cookies.addAll(getResponse.cookies);

      final html = await utf8.decodeStream(getResponse);

      final tokenRegex = RegExp(
        r'<input[^>]*name="_token"[^>]*value="([^"]+)"',
        caseSensitive: false,
      );

      final tokenMatch = tokenRegex.firstMatch(html);

      if (tokenMatch == null) {
        return LoginResult(
          success: false,
          status: 'Could not find CSRF token',
        );
      }

      final csrfToken = tokenMatch.group(1)!;

      print('GET status: ${getResponse.statusCode}');
      print('CSRF: $csrfToken');
      print('Cookies after GET: ${cookies.map((c) => '${c.name}=${c.value}').toList()}');

      final body = Uri(queryParameters: {
        '_token': csrfToken,
        'redirect_url': '',
        'identifier': email,
        'password': password,
        'remember_me': 'on',
      }).query;

      final postRequest = await client.postUrl(Uri.parse(loginUrl));

      postRequest.followRedirects = false;

      _addBrowserHeaders(postRequest);

      postRequest.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/x-www-form-urlencoded',
      );

      postRequest.headers.set(
        HttpHeaders.refererHeader,
        loginUrl,
      );

      postRequest.headers.set(
        'Origin',
        'https://jobinja.ir',
      );

      postRequest.headers.set(
        'X-CSRF-TOKEN',
        csrfToken,
      );

      postRequest.cookies.addAll(cookies);

      postRequest.write(body);

      final postResponse = await postRequest.close();

      final postBody = await utf8.decodeStream(postResponse);

      print('POST status: ${postResponse.statusCode}');
      print('POST reason: ${postResponse.reasonPhrase}');
      print('POST location: ${postResponse.headers.value(HttpHeaders.locationHeader)}');
      print('POST body: $postBody');

      if (postResponse.statusCode == 302) {
        final location = postResponse.headers.value(HttpHeaders.locationHeader) ?? '';

        if (location.isNotEmpty && !location.contains('/login/user')) {
          return LoginResult(success: true, status: '302');
        }

        return LoginResult(
          success: false,
          status: 'Invalid email or password',
        );
      }

      return LoginResult(
        success: false,
        status: 'Status code: ${postResponse.statusCode}',
      );
    } catch (e) {
      return LoginResult(
        success: false,
        status: e.toString(),
      );
    } finally {
      client.close();
    }
  }

  void _addBrowserHeaders(HttpClientRequest request) {
    request.headers.set(
      HttpHeaders.acceptHeader,
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    );

    request.headers.set(
      HttpHeaders.acceptLanguageHeader,
      'en-US,en;q=0.9,fa;q=0.8',
    );

    request.headers.set(
      HttpHeaders.userAgentHeader,
      'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    );
  }

  Future<void> main() async {
    const email = 'ThisIsATestMail@gmail.com';
    const password = 'Poria123';

    final result = await login(email, password);

    print('Login success: ${result.success}');
    print('Login status: ${result.status}');
  }
}

//Valid Username:
// User; ThisIsATestMail@gmail.com
// Pass: Poria123
