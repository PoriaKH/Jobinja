import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/signup_data.dart';
import '../presenters/signup_submit_presenter.dart';

class SignupSubmitWebViewScreen extends StatefulWidget {
  final SignupPreparationResult preparation;
  final SignupFormData formData;

  const SignupSubmitWebViewScreen({
    super.key,
    required this.preparation,
    required this.formData,
  });

  @override
  State<SignupSubmitWebViewScreen> createState() =>
      _SignupSubmitWebViewScreenState();
}

class _SignupSubmitWebViewScreenState extends State<SignupSubmitWebViewScreen>
    implements SignupSubmitView {
  WebViewController? controller;
  final WebViewCookieManager cookieManager = WebViewCookieManager();

  late SignupSubmitPresenter presenter;

  String message = 'Preparing registration...';
  bool closed = false;

  @override
  void initState() {
    super.initState();

    presenter = SignupSubmitPresenter(
      view: this,
      preparation: widget.preparation,
      formData: widget.formData,
    );

    presenter.start();
  }

  @override
  void showMessage(String message) {
    if (!mounted) return;

    setState(() {
      this.message = message;
    });
  }

  @override
  Future<void> clearWebViewCookies() async {
    await cookieManager.clearCookies();
  }

  @override
  void loadSignupUrl(String signupUrl) {
    final newController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'SignupChannel',
        onMessageReceived: (msg) {
          presenter.onJavaScriptMessage(msg.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: presenter.onPageStarted,
          onPageFinished: presenter.onPageFinished,
          onWebResourceError: (error) {
            presenter.onWebResourceError(error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(signupUrl));

    if (!mounted) return;

    setState(() {
      controller = newController;
    });
  }

  @override
  Future<void> runJavaScript(String script) async {
    await controller?.runJavaScript(script);
  }

  @override
  void closeWithSuccess() {
    if (closed || !mounted) return;
    closed = true;
    Navigator.pop(context, true);
  }

  @override
  void closeWithFailure(String message) {
    if (closed || !mounted) return;
    closed = true;
    Navigator.pop(context, false);
  }

  void goBack() {
    closeWithFailure('Signup cancelled.');
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBack,
        ),
      ),
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: !message.contains('Complete captcha'),
            child: WebViewWidget(controller: controller!),
          ),
          if (!message.contains('Complete captcha'))
            Positioned.fill(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}