import 'dart:convert';

import '../models/signup_data.dart';

abstract class SignupSubmitView {
  void showMessage(String message);
  void closeWithSuccess();
  void closeWithFailure(String message);
  Future<void> clearWebViewCookies();
  void loadSignupUrl(String signupUrl);
  Future<void> runJavaScript(String script);
}

class SignupSubmitPresenter {
  final SignupSubmitView view;
  final SignupPreparationResult preparation;
  final SignupFormData formData;

  bool submitted = false;
  bool closed = false;

  SignupSubmitPresenter({
    required this.view,
    required this.preparation,
    required this.formData,
  });

  Future<void> start() async {
    view.showMessage('Preparing registration...');
    await view.clearWebViewCookies();
    view.loadSignupUrl(preparation.signupUrl);
  }

  bool isSuccessUrl(String url) {
    return url.startsWith('https://jobinja.ir') &&
        !url.contains('/join/user');
  }

  void onPageStarted(String url) {
    if (submitted && isSuccessUrl(url)) {
      view.closeWithSuccess();
    }
  }

  Future<void> onPageFinished(String url) async {
    if (!submitted && url.contains('/join/user')) {
      submitted = true;
      await submitInsideWebView();
      return;
    }

    if (submitted && isSuccessUrl(url)) {
      view.closeWithSuccess();
    }
  }

  void onWebResourceError(String description) {
    view.showMessage('WebView error: $description');
  }

  void onJavaScriptMessage(String message) {
    view.showMessage(message);
  }

  Future<void> submitInsideWebView() async {
    final email = jsonEncode(formData.email);
    final fullName = jsonEncode(formData.fullName);
    final password = jsonEncode(formData.password);
    final confirmPassword = jsonEncode(formData.confirmPassword);

    await view.runJavaScript('''
      function sendMessage(message) {
        SignupChannel.postMessage(message);
      }

      sendMessage('Waiting for signup form...');

      let formTries = 0;

      const formInterval = setInterval(function() {
        formTries++;

        const emailInput = document.querySelector('input[name="email"]');
        const fullNameInput = document.querySelector('input[name="full_name"]');
        const passwordInput = document.querySelector('input[name="password"]');
        const confirmInput = document.querySelector('input[name="password_confirmation"]');
        const submitButton = document.querySelector('input[type="submit"]');
        const form = document.querySelector('form');

        if (emailInput && fullNameInput && passwordInput && confirmInput && submitButton && form) {
          clearInterval(formInterval);

          sendMessage('Filling signup form...');

          emailInput.value = $email;
          fullNameInput.value = $fullName;
          passwordInput.value = $password;
          confirmInput.value = $confirmPassword;

          emailInput.dispatchEvent(new Event('input', { bubbles: true }));
          fullNameInput.dispatchEvent(new Event('input', { bubbles: true }));
          passwordInput.dispatchEvent(new Event('input', { bubbles: true }));
          confirmInput.dispatchEvent(new Event('input', { bubbles: true }));

          sendMessage('Waiting for reCAPTCHA to become ready...');

          const captchaInterval = setInterval(function() {
            const captchaExists =
              typeof grecaptcha !== 'undefined' &&
              window.___grecaptcha_cfg &&
              window.___grecaptcha_cfg.clients &&
              Object.keys(window.___grecaptcha_cfg.clients).length > 0;

            if (captchaExists) {
              clearInterval(captchaInterval);

              sendMessage('Complete captcha if it appears.');

              emailInput.readOnly = true;
              fullNameInput.readOnly = true;
              passwordInput.readOnly = true;
              confirmInput.readOnly = true;

              const lockStyle = document.createElement('style');
              lockStyle.innerHTML = `
                body {
                  overflow: hidden !important;
                }

                form,
                header,
                .container,
                .c-muteHeader,
                .o-aligner,
                .c-socialLogins {
                  pointer-events: none !important;
                  user-select: none !important;
                }

                input,
                button,
                a,
                textarea,
                select {
                  pointer-events: none !important;
                }

                iframe[src*="recaptcha"],
                div[style*="z-index: 2000000000"],
                div[style*="z-index: 2000000000"] * {
                  pointer-events: auto !important;
                  user-select: auto !important;
                }
              `;

              document.head.appendChild(lockStyle);

              submitButton.click();
            }
          }, 500);
        }

        if (formTries > 40) {
          clearInterval(formInterval);
          sendMessage('Could not find all signup form elements.');
        }
      }, 500);
    ''');
  }
}