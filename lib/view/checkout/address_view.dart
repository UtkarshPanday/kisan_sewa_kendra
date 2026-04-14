import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../controller/auth_controller.dart';
import '../../controller/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding/geocoding.dart';

class AddressView extends StatefulWidget {
  const AddressView({super.key});

  @override
  State<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<AddressView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  bool _isPinLoading = false;
  bool _isProcessingCod = false;
  bool _isFetchingLocation = false;

  List<Map<String, String>> _addressList = [];
  int? _selectedIndex;
  bool _isAddingAddress = false;
  String? _savedName;
  String? _savedPhone;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final addresses = await AuthController.getStoredAddresses();
    final name = await AuthController.getSavedName();
    final phone = await AuthController.getSavedPhone();

    if (mounted) {
      setState(() {
        _addressList = addresses;
        _savedName = name;
        _savedPhone = phone;
        if (_addressList.isNotEmpty) {
          _selectedIndex = 0;
          _isAddingAddress = false;
        } else {
          _isAddingAddress = true;
          _preFillDetails();
        }
      });
    }
  }

  void _preFillDetails() {
    if (_savedName != null && _savedName!.isNotEmpty) {
      final parts = _savedName!.split(' ');
      _firstNameController.text = parts.first;
      _lastNameController.text =
          parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }
    if (_savedPhone != null) _phoneController.text = _savedPhone!;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _fetchPincodeData(String pincode) async {
    if (pincode.length != 6) return;
    setState(() => _isPinLoading = true);
    try {
      final res = await http.get(
        Uri.parse('https://api.postalpincode.in/pincode/$pincode'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List && data.isNotEmpty) {
          final postOffice = data[0];
          if (postOffice['Status'] == 'Success' &&
              postOffice['PostOffice'] != null &&
              (postOffice['PostOffice'] as List).isNotEmpty) {
            final po = postOffice['PostOffice'][0];
            if (mounted) {
              setState(() {
                _cityController.text = po['District'] ?? '';
                _stateController.text = po['State'] ?? '';
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Pincode fetch error: $e');
    }
    if (mounted) setState(() => _isPinLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location services are disabled.')));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Location permissions are denied.')));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Location permissions are permanently denied, we cannot request permissions.')));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if (mounted) {
          setState(() {
            _address1Controller.text = '${place.name}, ${place.subLocality}'
                .trim()
                .replaceAll(RegExp(r'^,\s*'), '');
            _address2Controller.text = '${place.locality}';
            _cityController.text =
                place.subAdministrativeArea ?? place.locality ?? '';
            _stateController.text = place.administrativeArea ?? '';

            if (place.postalCode != null && place.postalCode!.isNotEmpty) {
              _pincodeController.text = place.postalCode!;
              _fetchPincodeData(
                  place.postalCode!); // Auto-fetch city/state to be sure
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to get location: $e')));
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  void _proceed() {
    if (_isAddingAddress) {
      if (!_formKey.currentState!.validate()) return;
      _saveAndProceed();
    } else {
      if (_selectedIndex == null) return;
      Navigator.pop(context, _addressList[_selectedIndex!]);
    }
  }

  Future<void> _saveAndProceed() async {
    final addr = {
      'pincode': _pincodeController.text.trim(),
      'address1': _address1Controller.text.trim(),
      'address2': _address2Controller.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'name':
          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}"
              .trim(),
      'phone': _phoneController.text.trim(),
    };

    setState(() => _isProcessingCod = true);

    await AuthController.saveAddress(
      pincode: addr['pincode']!,
      address1: addr['address1']!,
      address2: addr['address2']!,
      city: addr['city']!,
      state: addr['state']!,
      name: addr['name'],
      firstName: addr['first_name'],
      lastName: addr['last_name'],
      phone: addr['phone'],
    );

    // Refresh list and select the new address
    final addresses = await AuthController.getStoredAddresses();
    if (mounted) {
      setState(() {
        _addressList = addresses;
        _selectedIndex = 0;
        _isAddingAddress = false;
        _isProcessingCod = false;
      });

      // Always pop back to the caller
      Navigator.pop(context, addr);
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    String? Function(String?)? validator,
    Widget? suffix,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: const Color(0xFF1E1E1E))),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onChanged: onChanged,
          style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
            suffixIcon: suffix,
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Constants.baseColor, width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.redAccent)),
          ),
          validator: validator ??
              (v) => (v == null || v.isEmpty) ? 'This field is required' : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffF9FBF9),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  16, MediaQuery.of(context).padding.top + 90, 16, 120),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isAddingAddress) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('New Delivery Address',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: const Color(0xFF1E1E1E))),
                          if (_addressList.isNotEmpty)
                            IconButton(
                              onPressed: () =>
                                  setState(() => _isAddingAddress = false),
                              icon: const Icon(Icons.close_rounded),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              controller: _firstNameController,
                              label: 'First Name',
                              hint: 'John',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              hint: 'Doe',
                            ),
                          ),
                        ],
                      ),
                      _buildField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'Enter Phone Number',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10)
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Please enter phone number';
                          if (v.length != 10)
                            return 'Enter valid 10-digit number';
                          return null;
                        },
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              _isFetchingLocation ? null : _getCurrentLocation,
                          icon: _isFetchingLocation
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Constants.baseColor))
                              : Icon(Icons.my_location_rounded,
                                  size: 18, color: Constants.baseColor),
                          label: Text(
                            _isFetchingLocation
                                ? 'Locating...'
                                : 'Use Current Location',
                            style: GoogleFonts.inter(
                                color: Constants.baseColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: Constants.baseColor.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor:
                                Constants.baseColor.withOpacity(0.04),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildField(
                        controller: _pincodeController,
                        label: 'Pincode',
                        hint: '411001',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        suffix: _isPinLoading
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Constants.baseColor)),
                              )
                            : null,
                        onChanged: (v) {
                          if (v.length == 6) _fetchPincodeData(v);
                        },
                      ),
                      _buildField(
                        controller: _address1Controller,
                        label: 'Address Line 1',
                        hint: 'House no., Street, Area',
                      ),
                      _buildField(
                        controller: _address2Controller,
                        label: 'Address Line 2 (Optional)',
                        hint: 'Landmark, Colony, etc.',
                        validator: (_) => null,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              controller: _cityController,
                              label: 'City / District',
                              hint: 'Pune',
                              readOnly: _cityController.text.isNotEmpty,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField(
                              controller: _stateController,
                              label: 'State',
                              hint: 'Maharashtra',
                              readOnly: _stateController.text.isNotEmpty,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery Address',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: const Color(0xFF1E1E1E))),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _firstNameController.clear();
                                _lastNameController.clear();
                                _address1Controller.clear();
                                _address2Controller.clear();
                                _pincodeController.clear();
                                _cityController.clear();
                                _stateController.clear();
                                _preFillDetails();
                                _isAddingAddress = true;
                              });
                            },
                            icon: const Icon(Icons.add_circle_outline_rounded,
                                size: 18),
                            label: Text('Add New',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700)),
                            style: TextButton.styleFrom(
                                foregroundColor: Constants.baseColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _addressList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final addr = _addressList[index];
                          final isSelected = _selectedIndex == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIndex = index),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Constants.baseColor
                                      : Colors.grey.withOpacity(0.1),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color:
                                          Constants.baseColor.withOpacity(0.1),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    color: isSelected
                                        ? Constants.baseColor
                                        : Colors.grey.withOpacity(0.3),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          addr['name'] ?? '',
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                              color: const Color(0xFF1E1E1E)),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${addr['address1']}, ${addr['address2'] ?? ""}',
                                          style: GoogleFonts.inter(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                              height: 1.4),
                                        ),
                                        Text(
                                          '${addr['city']}, ${addr['state']} - ${addr['pincode']}',
                                          style: GoogleFonts.inter(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await AuthController
                                          .removeAddressFromList(index);
                                      _loadAddresses();
                                    },
                                    icon: Icon(Icons.delete_outline_rounded,
                                        size: 20, color: Colors.red[300]),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Glassmorphism App Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAdvancedHeader(),
            ),
          ],
        ),
        bottomNavigationBar: _buildActionBottomBar(),
      ),
    );
  }

  Widget _buildAdvancedHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.of(context).padding.top + 10, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Constants.baseColor.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 22,
                    color: Constants.baseColor,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Address",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.eco_rounded,
                          size: 12, color: Constants.baseColor),
                      const SizedBox(width: 4),
                      Text(
                        "Pure Organic Agriculture",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Constants.baseColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 15, 20, MediaQuery.of(context).padding.bottom + 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: InkWell(
        onTap: (_selectedIndex == null && !_isAddingAddress) || _isProcessingCod
            ? null
            : _proceed,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: (_selectedIndex == null && !_isAddingAddress) ||
                    _isProcessingCod
                ? Colors.grey[300]
                : Constants.baseColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!((_selectedIndex == null && !_isAddingAddress) ||
                  _isProcessingCod))
                BoxShadow(
                  color: Constants.baseColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Center(
            child: _isProcessingCod
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text(
                    _isAddingAddress ? 'SAVE & CONFIRM' : 'CONFIRM ADDRESS',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.white,
                        letterSpacing: 0.5),
                  ),
          ),
        ),
      ),
    );
  }
}
