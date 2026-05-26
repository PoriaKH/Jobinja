import 'dart:convert';
import 'dart:io';

import '../models/user.dart';
import '../models/job.dart';

class LoginResult {
  final bool success;
  final String status;

  LoginResult({
    required this.success,
    required this.status,
  });
}

class ApiService {
  static const String loginUrl = 'https://jobinja.ir/login/user';
  static const String jobsUrl = 'https://jobinja.ir/jobs';

  final HttpClient _client = HttpClient();
  final List<Cookie> _cookies = [];

  Future<LoginResult> login(String email, String password) async {
    try {
      final getRequest = await _client.getUrl(Uri.parse(loginUrl));
      getRequest.persistentConnection = false;

      _addBrowserHeaders(getRequest);

      final getResponse = await getRequest.close();
      _saveCookies(getResponse.cookies);

      final html = await utf8.decodeStream(getResponse);

      final csrfToken = _extractCsrfToken(html);

      if (csrfToken == null) {
        return LoginResult(
          success: false,
          status: 'Could not find CSRF token',
        );
      }

      print('GET status: ${getResponse.statusCode}');
      print('Got CSRF: $csrfToken');

      final body = Uri(queryParameters: {
        '_token': csrfToken,
        'redirect_url': '',
        'identifier': email,
        'password': password,
        'remember_me': 'on',
      }).query;

      final postRequest = await _client.postUrl(Uri.parse(loginUrl));
      postRequest.persistentConnection = false;

      postRequest.followRedirects = false;

      _addBrowserHeaders(postRequest);

      postRequest.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/x-www-form-urlencoded',
      );

      postRequest.headers.set(HttpHeaders.refererHeader, loginUrl);
      postRequest.headers.set('Origin', 'https://jobinja.ir');
      postRequest.headers.set('X-CSRF-TOKEN', csrfToken);

      postRequest.cookies.addAll(_cookies);
      postRequest.write(body);

      final postResponse = await postRequest.close();
      _saveCookies(postResponse.cookies);

      final responseBody = await utf8.decodeStream(postResponse);
      final location =
          postResponse.headers.value(HttpHeaders.locationHeader) ?? '';

      print('LOGIN POST status: ${postResponse.statusCode}');
      print('LOGIN POST location: $location');

      if (postResponse.statusCode == 302 &&
          location.isNotEmpty &&
          !location.contains('/login/user')) {
        await _visitRedirectAfterLogin(location);

        return LoginResult(success: true, status: '200');
      }

      if (responseBody.contains('کاربری با این اطلاعات وجود ندارد')) {
        return LoginResult(
          success: false,
          status: 'Invalid email or password',
        );
      }

      return LoginResult(
        success: false,
        status: 'Login failed: ${postResponse.statusCode}',
      );
    } catch (e) {
      return LoginResult(success: false, status: e.toString());
    }
  }

  Future<void> _visitRedirectAfterLogin(String location) async {
    final request = await _client.getUrl(Uri.parse(location));
    request.persistentConnection = false;

    _addBrowserHeaders(request);

    request.headers.set(HttpHeaders.refererHeader, loginUrl);
    request.cookies.addAll(_cookies);

    final response = await request.close();

    _saveCookies(response.cookies);

    await utf8.decodeStream(response);

    print('REDIRECT status: ${response.statusCode}');
  }

  Future<List<Job>> getJobs() async {
    try {
      final request = await _client.getUrl(Uri.parse(jobsUrl));
      request.persistentConnection = false;

      _addBrowserHeaders(request);

      request.headers.set(HttpHeaders.refererHeader, 'https://jobinja.ir/');
      request.cookies.addAll(_cookies);

      final response = await request.close();

      _saveCookies(response.cookies);

      final html = await utf8.decodeStream(response);

      print('JOBS status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Jobs request failed: ${response.statusCode}');
      }

      if (html.contains('c-loginForm')) {
        throw Exception('User is not authenticated. Please login again.');
      }

      final jobs = _parseJobs(html);

      print('Parsed jobs count: ${jobs.length}');

      return jobs;
    } catch (e) {
      throw Exception('Could not load jobs: $e');
    }
  }

  List<Job> _parseJobs(String html) {
    final jobs = <Job>[];

    final jobRegex = RegExp(
      r'<h2[^>]*c-jobListView__title[^>]*>([\s\S]*?)</h2>\s*<ul[^>]*c-jobListView__meta[^>]*>([\s\S]*?)</ul>',
      caseSensitive: false,
    );

    final matches = jobRegex.allMatches(html);

    for (final match in matches) {
      final titleBlock = match.group(1) ?? '';
      final metaBlock = match.group(2) ?? '';

      final hrefMatch = RegExp(
        r'href="([^"]+)"',
        caseSensitive: false,
      ).firstMatch(titleBlock);

      final titleMatch = RegExp(
        r'<a[^>]*c-jobListView__titleLink[^>]*>([\s\S]*?)</a>',
        caseSensitive: false,
      ).firstMatch(titleBlock);

      final dateMatch = RegExp(
        r'<span[^>]*c-jobListView__passedDays[^>]*>([\s\S]*?)</span>',
        caseSensitive: false,
      ).firstMatch(titleBlock);

      final metaMatches = RegExp(
        r'<li[^>]*c-jobListView__metaItem[^>]*>([\s\S]*?)</li>',
        caseSensitive: false,
      ).allMatches(metaBlock).toList();

      final title = _cleanHtml(titleMatch?.group(1) ?? '');
      final publishDate = _cleanHtml(dateMatch?.group(1) ?? '');
      final detailUrl = _cleanHtml(hrefMatch?.group(1) ?? '');

      final companyName =
      metaMatches.isNotEmpty ? _cleanHtml(metaMatches[0].group(1) ?? '') : '';

      final location =
      metaMatches.length > 1 ? _cleanHtml(metaMatches[1].group(1) ?? '') : '';

      final cooperationType =
      metaMatches.length > 2 ? _cleanHtml(metaMatches[2].group(1) ?? '') : '';

      if (title.isEmpty) continue;

      jobs.add(
        Job(
          title: title,
          companyName: companyName,
          location: location,
          cooperationType: cooperationType,
          publishDate: publishDate,
          shortDescription: cooperationType,
          detailUrl: detailUrl.replaceAll('&amp;', '&'),
        ),
      );
    }

    return jobs;
  }

  String? _extractCsrfToken(String html) {
    final regex = RegExp(
      r'<input[^>]*name="_token"[^>]*value="([^"]+)"',
      caseSensitive: false,
    );

    return regex.firstMatch(html)?.group(1);
  }

  String _cleanHtml(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&zwnj;', '‌')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _saveCookies(List<Cookie> newCookies) {
    for (final newCookie in newCookies) {
      _cookies.removeWhere((oldCookie) => oldCookie.name == newCookie.name);
      _cookies.add(newCookie);
    }

    print('COOKIES: ${_cookies.map((c) => '${c.name}=${c.value}').toList()}');
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

  void dispose() {
    _client.close();
  }
}

//Valid Username:
// User; ThisIsATestMail@gmail.com
// Pass: Poria123