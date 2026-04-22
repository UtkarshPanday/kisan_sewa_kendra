import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controller/auth_controller.dart';
import '../../controller/constants.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';
import '../home_view.dart';

class OtpView extends StatefulWidget {
  final String phone;
  final String verificationId;

  const OtpView({
    super.key,
    required this.phone,
    required this.verificationId,
  });

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 30;
  Timer? _timer;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _startResendTimer();
    // Auto-focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendCountdown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _resendCountdown--);
      }
    });
  }

  String get _fullOtp => _controllers.map((c) => c.text).join();

  void _onOtpInput(int index, String value) {
    if (value.length == 1 && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    // Auto-submit when all 6 digits are filled
    if (_fullOtp.length == 6) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    if (_fullOtp.length < 6 || _isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final success = await AuthController.verifyOtp(
      verificationId: widget.verificationId,
      smsCode: _fullOtp,
      phone: widget.phone,
      onError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Clear OTP boxes on error
          for (var c in _controllers) {
            c.clear();
          }
          FocusScope.of(context).requestFocus(_focusNodes[0]);
        }
      },
    );

    if (success && mounted) {
      // Sync with Shopify in background
      AuthController.syncWithShopify(widget.phone);

      // Navigate to home
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => const MyHomePage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0 || _isResending) return;
    setState(() => _isResending = true);

    await AuthController.sendOtp(
      phone: widget.phone,
      onCodeSent: (_) {
        if (mounted) {
          setState(() => _isResending = false);
          _startResendTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.otpSentAgain),
              backgroundColor: Constants.baseColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onAutoVerified: () {
        if (mounted) {
          setState(() => _isResending = false);
          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (_, anim, __) => const MyHomePage(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
            (route) => false,
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isResending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(error),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating),
          );
        }
      },
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Constants.baseColor, width: 2),
          ),
        ),
        onChanged: (value) => _onOtpInput(index, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: Colors.grey.shade700, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Constants.baseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.sms_rounded,
                        color: Constants.baseColor, size: 32),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    AppLocalizations.of(context)!.verifyPhone,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      text: AppLocalizations.of(context)!.enterOtpPrompt,
                      style:
                          TextStyle(fontSize: 15, color: Colors.grey.shade500),
                      children: [
                        TextSpan(
                          text: '+91 ${widget.phone}',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // OTP Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) => _buildOtpBox(i)),
                  ),
                  const SizedBox(height: 36),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.baseColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : Text(AppLocalizations.of(context)!.verifyOtp,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Resend
                  Center(
                    child: _resendCountdown > 0
                        ? Text.rich(
                            TextSpan(
                              text: AppLocalizations.of(context)!.resendOtpIn,
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 14),
                              children: [
                                TextSpan(
                                  text:
                                      '0:${_resendCountdown.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                      color: Constants.baseColor,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: _resendOtp,
                            child: _isResending
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Constants.baseColor))
                                : Text(
                                    AppLocalizations.of(context)!.resendOtp,
                                    style: TextStyle(
                                        color: Constants.baseColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15),
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
