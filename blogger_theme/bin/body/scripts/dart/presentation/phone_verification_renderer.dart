import 'dart:html';
import 'dart:async';
import 'dart:js' as js;

class Country {
  final String code;
  final String name;
  final String flag;

  const Country({required this.code, required this.name, required this.flag});
}

class PhoneVerificationRenderer {
  static final PhoneVerificationRenderer _instance = PhoneVerificationRenderer._internal();
  dynamic confirmationResult;
  Timer? resendTimer;
  int countdown = 60;

  Country selectedCountry = const Country(code: '+91', name: 'India', flag: '🇮🇳');

  final List<Country> countries = const [
    Country(code: '+91', name: 'India', flag: '🇮🇳'),
    Country(code: '+1', name: 'USA', flag: '🇺🇸'),
    Country(code: '+44', name: 'UK', flag: '🇬🇧'),
    Country(code: '+971', name: 'UAE', flag: '🇦🇪'),
    Country(code: '+65', name: 'Singapore', flag: '🇸🇬'),
  ];

  PhoneVerificationRenderer._internal();

  factory PhoneVerificationRenderer() {
    return _instance;
  }

  void render() {
    var modal = document.getElementById('antinna-phone-modal');
    if (modal == null) {
      modal = DivElement()
        ..id = 'antinna-phone-modal'
        ..className = 'antinna-geo-backdrop';

      final countryItemsHtml = countries.map((c) => '''
        <div class="antinna-country-item" data-code="${c.code}">
          <span class="antinna-country-flag">${c.flag}</span>
          <span class="antinna-country-name">${c.name}</span>
          <span class="antinna-country-code">${c.code}</span>
        </div>
      ''').join('');

      modal.setInnerHtml('''
        <div class="antinna-geo-content">
          <div class="antinna-geo-header">
            <h3>Phone Verification</h3>
            <button class="antinna-geo-close" id="antinna-phone-modal-close">&times;</button>
          </div>
          <p class="antinna-geo-subtitle">
            Please link your phone number to continue with the order.
          </p>

          <div id="phone-input-container">
            <div class="antinna-geo-search-container antinna-input-prefixed">
              <div id="antinna-country-trigger" class="antinna-country-selector" style="position:relative; display:flex; align-items:center; gap:6px; cursor:pointer;">
                <span id="antinna-selected-flag">${selectedCountry.flag}</span>
                <span id="antinna-selected-code">${selectedCountry.code}</span>
                <span class="antinna-country-chevron">▼</span>
                <div id="antinna-country-list" class="antinna-country-list" style="position:absolute; top:100%; left:0; display:none; background:#fff; border:1px solid #ccc; z-index:100; max-height:200px; overflow-y:auto; width:200px;">
                  $countryItemsHtml
                </div>
              </div>
              <input id="antinna-phone-number" type="tel" placeholder="98765 43210" autocomplete="off" style="border:none; outline:none; padding:8px; width:100%;">
            </div>
            <div id="recaptcha-container" style="margin-top:15px;"></div>
            <button id="antinna-send-otp-btn" class="v-btn active" style="width:100%; margin-top:20px; display:flex; align-items:center; justify-content:center;">
              <span class="btn-text">Send OTP</span>
            </button>
          </div>

          <div id="otp-input-container" style="display:none;">
            <div class="antinna-geo-search-container">
              <input id="antinna-otp-code" type="text" placeholder="Enter 6-digit OTP" maxlength="6" autocomplete="off">
            </div>
            <div id="antinna-resend-container" style="margin-top:15px; font-size:0.85rem; text-align:center; color:#777;">
              Didn't receive code? <button id="antinna-resend-btn" disabled style="background:none; border:none; color:var(--accent); font-weight:700; cursor:pointer; opacity:0.5;">Resend (<span id="antinna-countdown">60</span>s)</button>
            </div>
            <button id="antinna-verify-otp-btn" class="v-btn active" style="width:100%; margin-top:20px; display:flex; align-items:center; justify-content:center;">
              <span class="btn-text">Verify & Link</span>
            </button>
            <button class="qty-btn" id="antinna-otp-back" style="border:none; margin-top:10px; background:none; width:100%;">Back</button>
          </div>
        </div>
      ''', treeSanitizer: NodeTreeSanitizer.trusted);

      document.body.append(modal);
      setupListeners();
    }

    modal.classes.add('active');
  }

  void setupListeners() {
    final closeBtn = document.getElementById('antinna-phone-modal-close');
    closeBtn?.onClick.listen((_) {
      document.getElementById('antinna-phone-modal')?.classes.remove('active');
    });

    final trigger = document.getElementById('antinna-country-trigger');
    final list = document.getElementById('antinna-country-list');

    trigger?.onClick.listen((e) {
      e.stopPropagation();
      if (list != null) {
        final isHidden = list.style.display == 'none';
        list.style.display = isHidden ? 'block' : 'none';
      }
    });

    document.querySelectorAll('.antinna-country-item').forEach((item) {
      if (item is Element) {
        item.onClick.listen((e) {
          e.stopPropagation();
          final code = item.getAttribute('data-code');
          if (code != null) {
            setCountry(code);
          }
          if (list != null) list.style.display = 'none';
        });
      }
    });

    document.onClick.listen((_) {
      if (list != null) list.style.display = 'none';
    });

    final sendBtn = document.getElementById('antinna-send-otp-btn');
    sendBtn?.onClick.listen((_) => handleSendOTP());

    final verifyBtn = document.getElementById('antinna-verify-otp-btn');
    verifyBtn?.onClick.listen((_) => handleVerifyOTP());

    final backBtn = document.getElementById('antinna-otp-back');
    backBtn?.onClick.listen((_) {
      document.getElementById('phone-input-container')?.style.display = 'block';
      document.getElementById('otp-input-container')?.style.display = 'none';
    });
  }

  void setCountry(String code) {
    final country = countries.firstWhere((c) => c.code == code, orElse: () => selectedCountry);
    selectedCountry = country;
    document.getElementById('antinna-selected-flag')?.text = country.flag;
    document.getElementById('antinna-selected-code')?.text = country.code;
  }

  void startResendTimer() {
    resendTimer?.cancel();
    countdown = 60;

    final container = document.getElementById('antinna-resend-container');
    if (container != null) {
      container.setInnerHtml('Didn\'t receive code? <button id="antinna-resend-btn" disabled style="background:none; border:none; color:var(--accent); font-weight:700; cursor:pointer; opacity:0.5;">Resend (<span id="antinna-countdown">60</span>s)</button>', treeSanitizer: NodeTreeSanitizer.trusted);
    }

    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown--;
      document.getElementById('antinna-countdown')?.text = countdown.toString();

      if (countdown <= 0) {
        timer.cancel();
        if (container != null) {
          container.setInnerHtml('Didn\'t receive code? <button id="antinna-resend-btn" style="background:none; border:none; color:var(--accent); font-weight:700; cursor:pointer;">Resend Now</button>', treeSanitizer: NodeTreeSanitizer.trusted);
          document.getElementById('antinna-resend-btn')?.onClick.listen((_) => handleSendOTP());
        }
      }
    });
  }

  void _showToast(String message, String type) {
    if (js.context['showToast'] != null) {
      js.context.callMethod('showToast', [message, type]);
    } else {
      window.alert(message);
    }
  }

  Future<void> handleSendOTP() async {
    final phoneInput = document.getElementById('antinna-phone-number') as InputElement?;
    var phone = phoneInput?.value?.trim().replaceAll(RegExp(r'\D'), '') ?? '';

    if (phone.isEmpty || phone.length < 7) {
      _showToast('Enter a valid phone number', 'error');
      return;
    }

    phone = selectedCountry.code + phone;

    final auth = js.context['firebaseAuth'];
    final user = auth != null ? auth['currentUser'] : null;
    if (user == null) {
      _showToast('Authentication required', 'error');
      return;
    }

    final recaptchaClass = js.context['RecaptchaVerifier'];
    final linkWithPhoneNumber = js.context['linkWithPhoneNumber'];

    if (recaptchaClass == null || linkWithPhoneNumber == null) {
      _showToast('Auth engine not fully loaded', 'error');
      return;
    }

    final sendBtn = document.getElementById('antinna-send-otp-btn') as ButtonElement?;
    if (sendBtn != null) {
      sendBtn.disabled = true;
      sendBtn.text = 'Sending...';
    }

    try {
      if (js.context['recaptchaVerifier'] == null) {
        js.context['recaptchaVerifier'] = js.JsObject(recaptchaClass as js.JsFunction, [
          auth,
          'recaptcha-container',
          js.JsObject.jsify({'size': 'invisible'}),
        ]);
      }

      final verifier = js.context['recaptchaVerifier'];

      final promise = js.context.callMethod('linkWithPhoneNumber', [user, phone, verifier]);
      confirmationResult = await js.context['Promise'].callMethod('resolve', [promise]);

      document.getElementById('phone-input-container')?.style.display = 'none';
      document.getElementById('otp-input-container')?.style.display = 'block';
      _showToast('OTP sent successfully!', 'success');
      startResendTimer();
    } catch (error) {
      print('Phone linking failed: $error');
      _showToast('Failed to send OTP', 'error');
    } finally {
      if (sendBtn != null) {
        sendBtn.disabled = false;
        sendBtn.text = 'Send OTP';
      }
    }
  }

  Future<void> handleVerifyOTP() async {
    final otpInput = document.getElementById('antinna-otp-code') as InputElement?;
    final code = otpInput?.value?.trim() ?? '';
    if (code.isEmpty || code.length != 6) {
      _showToast('Enter a valid 6-digit OTP', 'error');
      return;
    }

    if (confirmationResult == null) return;

    final verifyBtn = document.getElementById('antinna-verify-otp-btn') as ButtonElement?;
    if (verifyBtn != null) {
      verifyBtn.disabled = true;
      verifyBtn.text = 'Verifying...';
    }

    try {
      final promise = (confirmationResult as js.JsObject).callMethod('confirm', [code]);
      await js.context['Promise'].callMethod('resolve', [promise]);

      _showToast('Phone linked successfully!', 'success');
      document.getElementById('antinna-phone-modal')?.classes.remove('active');
      js.context['hasPhoneLinked'] = true;

      resendTimer?.cancel();
    } catch (error) {
      print('OTP Verification failed: $error');
      _showToast('OTP Verification failed', 'error');
    } finally {
      if (verifyBtn != null) {
        verifyBtn.disabled = false;
        verifyBtn.text = 'Verify & Link';
      }
    }
  }
}
