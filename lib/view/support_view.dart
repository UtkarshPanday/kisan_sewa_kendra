import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/constants.dart';

class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _submitToWhatsApp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    final fullMessage =
        "Name: $name\nPhone: $phone\nEmail: $email\nMessage: $message";
    final encodedMessage = Uri.encodeComponent(fullMessage);

    final whatsappUrl =
        Uri.parse("https://wa.me/919399022060?text=$encodedMessage");
    final playStoreUrl =
        Uri.parse("https://play.google.com/store/apps/details?id=com.whatsapp");

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to process request"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _callUs() async {
    final url = Uri.parse("tel:919399022060");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _openEmail() async {
    final url =
        Uri.parse("mailto:${AppLocalizations.of(context)!.officeEmail}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xffF9FBF9),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── GRADIENT HEADER ───
                _buildHeader(),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // ─── CONTACT FORM ───
                      _buildFormCard(),

                      const SizedBox(height: 16),

                      // ─── ADDRESS / LOCATION ───
                      _buildAddressCard(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  GRADIENT HEADER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 16,
            16,
            24,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Constants.baseColor.withOpacity(0.9),
                Constants.baseColor,
                Constants.baseColor.withOpacity(0.8),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          // We wrap the child Column in a Stack as well to place the background icon
          // inside the container so it respects the border radius and background.
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ─── DECORATIVE BACKDROP ICON ───
              Positioned(
                right: -20,
                top: -60,
                child: Icon(
                  Icons.support_agent_rounded,
                  size: 200,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),

              // ─── FOREGROUND CONTENT ───
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with back-style icon and phone
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _callUs,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone_rounded,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.of(context)!.callNow,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppLocalizations.of(context)!.helpSupport,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.supportSubtitle,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  CONTACT FORM
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Constants.baseColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Constants.baseColor.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: Constants.baseColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.sendMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B2B1C),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.replyTime,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Form fields
            _field(
              label: AppLocalizations.of(context)!.fullName,
              icon: Icons.person_outline_rounded,
              controller: _nameController,
              validator: (v) =>
                  v!.isEmpty ? AppLocalizations.of(context)!.enterName : null,
            ),
            _field(
              label: AppLocalizations.of(context)!.phoneNumber,
              icon: Icons.phone_android_rounded,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty)
                  return AppLocalizations.of(context)!.enterMobile;
                if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                  return AppLocalizations.of(context)!.enterMobile;
                }
                return null;
              },
            ),
            _field(
              label: AppLocalizations.of(context)!.emailAddress,
              icon: Icons.email_outlined,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty)
                  return AppLocalizations.of(context)!.enterEmail;
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                  return AppLocalizations.of(context)!.enterEmail;
                }
                return null;
              },
            ),
            _field(
              label: AppLocalizations.of(context)!.yourMessage,
              icon: Icons.chat_bubble_outline_rounded,
              maxLines: 3,
              controller: _messageController,
              validator: (v) => (v == null || v.length < 3)
                  ? AppLocalizations.of(context)!.minCharacters
                  : null,
            ),

            const SizedBox(height: 4),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitToWhatsApp,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(FontAwesomeIcons.whatsapp, size: 18),
                label: Text(
                  _isLoading
                      ? AppLocalizations.of(context)!.sending
                      : AppLocalizations.of(context)!.sendWhatsApp,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.baseColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextEditingController? controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 13.5, color: Colors.grey[500]),
          prefixIcon: Icon(icon, size: 20, color: Colors.grey[400]),
          floatingLabelStyle: TextStyle(
            color: Constants.baseColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: const Color(0xFFF7F8FA),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Constants.baseColor, width: 1.5),
          ),
          errorStyle: const TextStyle(fontSize: 11, height: 1),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  ADDRESS CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAddressCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Constants.baseColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Constants.baseColor.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFE53935),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.headOffice,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1B2B1C),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.officeAddress,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Email row
            Card(
              elevation: 0,
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: _openEmail,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.officeEmail,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
