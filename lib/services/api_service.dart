import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/LoginResult.dart';
import '../models/LogoutResult.dart';
import '../models/ProfileResult.dart';
import '../models/user.dart';
import '../models/job.dart';
import '../models/job_detail.dart';
import '../models/company.dart';
import '../models/signup_data.dart';


class ApiService {
  static const String loginUrl = 'https://jobinja.ir/login/user';
  static const String jobsUrl = 'https://jobinja.ir/jobs';
  static const String accountUrl = 'https://jobinja.ir/account';
  static const String logoutUrl = 'https://jobinja.ir/logout';
  static const String signupUrl = 'https://jobinja.ir/join/user';
  static const String profileImagePathKey = 'profile_image_path';

  Future<void> saveProfileImagePath(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(profileImagePathKey, imagePath);
  }

  Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(profileImagePathKey);
  }

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

  User _parseProfile(String html) {
    final emailMatch = RegExp(
      r'data-email="([^"]+)"',
      caseSensitive: false,
    ).firstMatch(html);

    final fullNameMatch = RegExp(
      r'v-model="full_name"[^>]*value="([^"]*)"',
      caseSensitive: false,
    ).firstMatch(html);

    final email = _cleanHtml(emailMatch?.group(1) ?? '');
    final fullName = _cleanHtml(fullNameMatch?.group(1) ?? '');

    if (email.isEmpty && fullName.isEmpty) {
      throw Exception('Could not parse profile data.');
    }

    return User(
      email: email,
      name: fullName,
    );
  }
  
  Future<ProfileResult> getProfile() async {
    //TODO...
    try {
      await Future.delayed(const Duration(seconds: 1));

      final request = await _client.getUrl(Uri.parse(accountUrl));
      request.persistentConnection = false;

      _addBrowserHeaders(request);

      request.headers.set(HttpHeaders.refererHeader, 'https://jobinja.ir/');
      request.cookies.addAll(_cookies);

      final response = await request.close();

      _saveCookies(response.cookies);

      final html = await utf8.decodeStream(response);

      print('PROFILE status: ${response.statusCode}');
      print('PROFILE body length: ${html.length}');

      if (response.statusCode != 200) {
        print('PROFILE body: $html');
        throw Exception('Profile request failed: ${response.statusCode}');
      }

      if (html.contains('c-loginForm')) {
        throw Exception('User is not authenticated. Please login again.');
      }

      final user = _parseProfile(html);

      print('Profile email: ${user.email}');
      print('Profile full name: ${user.name}');
      
      ProfileResult profileResult = ProfileResult(success: true, status: "200", user: user);
      return profileResult;
    } catch (e) {
      return ProfileResult(success: false, status: "Something went wrong. Profile not found!", user: null);
    }

    // return ProfileResult(success: true, status: "status", user: User(name: 'Test_Sample', email: 'TestMail@gmail.com'));
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

  Future<LogoutResult> logoutRequest() async{
    // TODO... Send logout request to the server

    // TODO... For now sending a sample logout. must be completed later

    try {
      final request = await _client.getUrl(Uri.parse(logoutUrl));

      request.persistentConnection = false;

      _addBrowserHeaders(request);

      request.headers.set(
        HttpHeaders.refererHeader,
        'https://jobinja.ir/',
      );

      request.cookies.addAll(_cookies);

      final response = await request.close();

      _saveCookies(response.cookies);

      final body = await utf8.decodeStream(response);

      print('LOGOUT status: ${response.statusCode}');
      print('LOGOUT body length: ${body.length}');

      if (response.statusCode == 200 ||
          response.statusCode == 302) {

        _cookies.clear();
        dispose();

        return LogoutResult(
          success: true,
          status: response.statusCode.toString(),
        );
      }

      return LogoutResult(
        success: false,
        status: 'Logout failed: ${response.statusCode}',
      );

    } catch (e) {
      return LogoutResult(
        success: false,
        status: e.toString(),
      );
    }

    // _cookies.clear();
    // dispose();
    //
    // return LogoutResult(success: true, status: "200");
  }
  Future<JobDetail> getJobDetail(String detailUrl) async {
    try {
      final request = await _client.getUrl(Uri.parse(detailUrl));

      request.persistentConnection = false;

      _addBrowserHeaders(request);

      request.headers.set(HttpHeaders.refererHeader, jobsUrl);
      request.cookies.addAll(_cookies);

      final response = await request.close();

      _saveCookies(response.cookies);

      final html = await utf8.decodeStream(response);

      print('JOB DETAIL status: ${response.statusCode}');
      print('JOB DETAIL body length: ${html.length}');

      if (response.statusCode != 200) {
        throw Exception('Job detail request failed: ${response.statusCode}');
      }

      if (html.contains('c-loginForm')) {
        throw Exception('User is not authenticated. Please login again.');
      }

      return _parseJobDetail(html);
    } catch (e) {
      throw Exception('Could not load job detail: $e');
    }
  }

  JobDetail _parseJobDetail(String html) {
    final title = _cleanHtml(
      RegExp(
        r'<h1[^>]*>([\s\S]*?)</h1>',
        caseSensitive: false,
      ).firstMatch(html)?.group(1) ?? '',
    );

    final companyName = _cleanHtml(
      RegExp(
        r'<h2[^>]*class="[^"]*c-companyHeader__name[^"]*"[^>]*>([\s\S]*?)</h2>',
        caseSensitive: false,
      ).firstMatch(html)?.group(1) ?? '',
    );

    final companyBaseUrl = _cleanHtml(
      RegExp(
        r'<a[^>]*class="[^"]*c-companyHeader__logoLink[^"]*"[^>]*href="([^"]+)"',
        caseSensitive: false,
      ).firstMatch(html)?.group(1) ?? '',
    );

    final companyJobsUrl = companyBaseUrl.isEmpty ? '' : '$companyBaseUrl/jobs';

    final location = _extractInfoBoxValue(html, 'موقعیت مکانی');
    final cooperationType = _extractInfoBoxValue(html, 'نوع همکاری');
    final seniority = _extractInfoBoxValue(html, 'حداقل سابقه کار');

    final salary = _extractInfoBoxValue(html, 'حقوق');
    final gender = _extractInfoBoxValue(html, 'جنسیت');
    final military = _extractInfoBoxValue(html, 'وضعیت نظام وظیفه');
    final education = _extractInfoBoxValue(html, 'حداقل مدرک تحصیلی');

    final skills = _extractInfoBoxValue(html, 'مهارت‌های مورد نیاز');

    final description = _extractSectionText(html, 'شرح موقعیت شغلی');
    final companyDescription = _extractSectionText(html, 'معرفی شرکت');

    return JobDetail(
      title: title,
      companyName: companyName,
      location: location,
      cooperationType: cooperationType,
      seniority: seniority,
      description: description,
      skills: skills,
      conditions:
      'Salary: $salary\nGender: $gender\nMilitary Status: $military\nEducation: $education',
      benefits: companyDescription.isEmpty
          ? 'No benefits/company description found.'
          : companyDescription,
      companyUrl: companyJobsUrl,
    );
  }

  String _extractInfoBoxValue(String html, String title) {
    final itemRegex = RegExp(
      r'<li[^>]*class="[^"]*c-infoBox__item[^"]*"[^>]*>([\s\S]*?)</li>',
      caseSensitive: false,
    );

    for (final itemMatch in itemRegex.allMatches(html)) {
      final itemHtml = itemMatch.group(1) ?? '';

      final titleMatch = RegExp(
        r'<h4[^>]*class="[^"]*c-infoBox__itemTitle[^"]*"[^>]*>([\s\S]*?)</h4>',
        caseSensitive: false,
      ).firstMatch(itemHtml);

      final itemTitle = _cleanHtml(titleMatch?.group(1) ?? '');

      if (itemTitle == title) {
        final values = RegExp(
          r'<span[^>]*class="[^"]*black[^"]*"[^>]*>([\s\S]*?)</span>',
          caseSensitive: false,
        )
            .allMatches(itemHtml)
            .map((match) => _cleanHtml(match.group(1) ?? ''))
            .where((value) => value.isNotEmpty)
            .toList();

        return values.join(', ');
      }
    }

    return '';
  }

  String _extractSectionText(String html, String title) {
    final regex = RegExp(
      '<h4[^>]*class="[^"]*o-box__title[^"]*"[^>]*>\\s*${RegExp.escape(title)}\\s*</h4>'
      r'\s*<div[^>]*class="[^"]*o-box__text[^"]*"[^>]*>([\s\S]*?)(?=<h4[^>]*class="[^"]*o-box__title|<ul[^>]*class="[^"]*c-infoBox|<hr|</section>)',
      caseSensitive: false,
    );

    final match = regex.firstMatch(html);

    return _cleanMultilineHtml(match?.group(1) ?? '');
  }

  String _cleanMultilineHtml(String value) {
    return value
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&zwnj;', '‌')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n+'), '\n')
        .trim();
  }
  Future<Company> getCompany(String companyUrl) async {
    try {
      final request = await _client.getUrl(Uri.parse(companyUrl));

      request.persistentConnection = false;

      _addBrowserHeaders(request);

      request.headers.set(HttpHeaders.refererHeader, 'https://jobinja.ir/');
      request.cookies.addAll(_cookies);

      final response = await request.close();

      _saveCookies(response.cookies);

      final html = await utf8.decodeStream(response);

      print('COMPANY status: ${response.statusCode}');
      print('COMPANY body length: ${html.length}');

      if (response.statusCode != 200) {
        throw Exception('Company request failed: ${response.statusCode}');
      }

      if (html.contains('c-loginForm')) {
        throw Exception('User is not authenticated. Please login again.');
      }

      return _parseCompany(html);
    } catch (e) {
      throw Exception('Could not load company: $e');
    }
  }
  Company _parseCompany(String html) {
    final name = _cleanHtml(
      RegExp(
        r'<h2[^>]*class="[^"]*c-companyHeader__name[^"]*"[^>]*>([\s\S]*?)</h2>',
        caseSensitive: false,
      ).firstMatch(html)?.group(1) ?? '',
    );

    final logoUrl = _cleanHtml(
      RegExp(
        r'<img[^>]*class="[^"]*c-companyHeader__logoImage[^"]*"[^>]*src="([^"]+)"',
        caseSensitive: false,
      ).firstMatch(html)?.group(1) ?? '',
    );

    final metaItems = RegExp(
      r'<span[^>]*class="[^"]*c-companyHeader__metaItem[^"]*"[^>]*>([\s\S]*?)</span>',
      caseSensitive: false,
    )
        .allMatches(html)
        .map((match) => _cleanHtml(match.group(1) ?? ''))
        .where((item) => item.isNotEmpty)
        .toList();

    final industry = metaItems.isNotEmpty ? metaItems[0] : '';
    final website = metaItems.length > 2 ? metaItems[2] : '';

    final description = _cleanMultilineHtml(
      RegExp(
        r'<section[^>]*class="[^"]*c-cardText[^"]*"[^>]*>[\s\S]*?<div[^>]*class="[^"]*c-cardText__body[^"]*"[^>]*>([\s\S]*?)</div>\s*</section>',
        caseSensitive: false,
      ).firstMatch(html)?.group(1) ?? '',
    );

    final jobs = _parseJobs(html);

    return Company(
      name: name,
      logoUrl: logoUrl,
      description: description,
      industry: industry,
      website: website,
      activeJobs: jobs,
    );
  }
//   From Here
  Future<SignupPreparationResult> prepareSignup() async {
    try {
      final request = await _client.getUrl(Uri.parse(signupUrl));
      request.persistentConnection = false;

      _addBrowserHeaders(request);

      final response = await request.close();
      _saveCookies(response.cookies);

      final html = await utf8.decodeStream(response);

      print('SIGNUP GET status: ${response.statusCode}');

      if (response.statusCode != 200) {
        return SignupPreparationResult(
          success: false,
          status: 'Signup page failed: ${response.statusCode}',
          csrfToken: '',
          signupUrl: signupUrl,
        );
      }

      final csrfToken = _extractCsrfToken(html);

      if (csrfToken == null || csrfToken.isEmpty) {
        return SignupPreparationResult(
          success: false,
          status: 'Could not find signup CSRF token',
          csrfToken: '',
          signupUrl: signupUrl,
        );
      }

      print('SIGNUP CSRF: $csrfToken');

      return SignupPreparationResult(
        success: true,
        status: '200',
        csrfToken: csrfToken,
        signupUrl: signupUrl,
      );
    } catch (e) {
      return SignupPreparationResult(
        success: false,
        status: e.toString(),
        csrfToken: '',
        signupUrl: signupUrl,
      );
    }
  }

  Future<SignupResult> submitSignup({
    required String csrfToken,
    required String email,
    required String fullName,
    required String password,
    required String passwordConfirmation,
    required String recaptchaToken,
  }) async {
    try {
      final body = Uri(queryParameters: {
        '_token': csrfToken,
        'redirect_url': '',
        'email': email,
        'full_name': fullName,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'g-recaptcha-response': recaptchaToken,
      }).query;

      final request = await _client.postUrl(Uri.parse(signupUrl));
      request.persistentConnection = false;
      request.followRedirects = false;

      _addBrowserHeaders(request);

      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/x-www-form-urlencoded',
      );

      request.headers.set(HttpHeaders.refererHeader, signupUrl);
      request.headers.set('Origin', 'https://jobinja.ir');
      request.headers.set('X-CSRF-TOKEN', csrfToken);

      request.cookies.addAll(_cookies);
      request.write(body);

      final response = await request.close();
      _saveCookies(response.cookies);

      final responseBody = await utf8.decodeStream(response);
      final location =
          response.headers.value(HttpHeaders.locationHeader) ?? '';

      print('SIGNUP POST status: ${response.statusCode}');
      print('SIGNUP POST location: $location');
      print('SIGNUP POST body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 302) {
        return SignupResult(
          success: true,
          status: response.statusCode.toString(),
        );
      }

      return SignupResult(
        success: false,
        status: 'Signup failed: ${response.statusCode}',
      );
    } catch (e) {
      return SignupResult(
        success: false,
        status: e.toString(),
      );
    }
  }
// To Here
}

//Valid Username:
// User; ThisIsATestMail@gmail.com
// Pass: Poria123