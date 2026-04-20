import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'otp_view.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';
import '../home_view.dart';
import '../../controller/auth_controller.dart';
import '../../controller/constants.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _cooldown = 0;
  Timer? _cooldownTimer;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _animController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldown = 30);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldown == 0) {
        timer.cancel();
      } else {
        if (mounted) setState(() => _cooldown--);
      }
    });
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cooldown > 0) return;
    setState(() => _isLoading = true);

    await AuthController.sendOtp(
      phone: _phoneController.text.trim(),
      onCodeSent: (verificationId) {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpView(
                phone: _phoneController.text.trim(),
                verificationId: verificationId,
              ),
            ),
          );
        }
      },
      onAutoVerified: () {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MyHomePage()),
            (route) => false,
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          _startCooldown(); // Start cooldown on error to prevent spamming
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Header Section
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          // Logo / Brand
                          Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                              'assets/logo-removebg-preview.png',
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Heading
                          Text(
                            AppLocalizations.of(context)!.welcomeTo,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: Colors.grey.shade900,
                                  letterSpacing: -1,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.loginPrompt,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Phone field
                    Text(
                      AppLocalizations.of(context)!.mobileNumber,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2),
                      decoration: InputDecoration(
                        counterText: '',
                        prefixIcon: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Constants.baseColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+91',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Constants.baseColor,
                            ),
                          ),
                        ),
                        hintText: AppLocalizations.of(context)!.enterMobile,
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, letterSpacing: 0.5),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: Constants.baseColor, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return AppLocalizations.of(context)!.enterMobileValid;
                        if (value.length != 10)
                          return AppLocalizations.of(context)!.enterMobile10;
                        return null;
                      },
                    ),
                    const SizedBox(height: 36),

                    // Send OTP Button
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed:
                            (_isLoading || _cooldown > 0) ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.baseColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _cooldown > 0
                                    ? AppLocalizations.of(context)!
                                        .tryAgainIn(_cooldown)
                                    : AppLocalizations.of(context)!.sendOtp,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.verificationSentMsg,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade400),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Terms
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.agreeTermsMsg,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade400),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse(
                                  'https://krishibhandar.com/pages/terms-condition?_pos=1&_psq=terms&_ss=e&_v=1.0');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            child: Text(
                              AppLocalizations.of(context)!.termsConditions,
                              style: TextStyle(
                                fontSize: 12,
                                color: Constants.baseColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.and,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade400),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse(
                                  'https://krishibhandar.com/pages/privacy-policy?_pos=1&_sid=640bbf90d&_ss=r');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            child: Text(
                              AppLocalizations.of(context)!.privacyPolicy,
                              style: TextStyle(
                                fontSize: 12,
                                color: Constants.baseColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
