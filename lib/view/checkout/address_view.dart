import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../controller/auth_controller.dart';
import '../../controller/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'checkout_view.dart';

class AddressView extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalValue;

  const AddressView({
    super.key,
    required this.cartItems,
    required this.totalValue,
  });

  @override
  State<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<AddressView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
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
        if (_addressList.isNotEmpty) {
          _selectedIndex = 0;
          _isAddingAddress = false;
        } else {
          _isAddingAddress = true;
          // Pre-fill name and phone for the first address
          if (name != null) _nameController.text = name;
          if (phone != null) _phoneController.text = phone;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
        return;
      } 

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if (mounted) {
          setState(() {
            _address1Controller.text = '${place.name}, ${place.subLocality}'.trim().replaceAll(RegExp(r'^,\s*'), '');
            _address2Controller.text = '${place.locality}';
            _cityController.text = place.subAdministrativeArea ?? place.locality ?? '';
            _stateController.text = place.administrativeArea ?? '';
            
            if (place.postalCode != null && place.postalCode!.isNotEmpty) {
               _pincodeController.text = place.postalCode!;
               _fetchPincodeData(place.postalCode!); // Auto-fetch city/state to be sure
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  void _navigateToCheckout(Map<String, String> addressData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutView(
          cartItems: widget.cartItems,
          totalValue: widget.totalValue,
          selectedAddress: addressData,
        ),
      ),
    );
  }

  void _proceed() {
    if (_isAddingAddress) {
      if (!_formKey.currentState!.validate()) return;
      _saveAndProceed();
    } else {
      if (_selectedIndex == null) return;
      _navigateToCheckout(_addressList[_selectedIndex!]);
    }
  }

  Future<void> _saveAndProceed() async {
    final addr = {
      'pincode': _pincodeController.text.trim(),
      'address1': _address1Controller.text.trim(),
      'address2': _address2Controller.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    setState(() => _isProcessingCod = true); // Using this for general loading
    
    await AuthController.saveAddress(
      pincode: addr['pincode']!,
      address1: addr['address1']!,
      address2: addr['address2']!,
      city: addr['city']!,
      state: addr['state']!,
      name: addr['name'],
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
      _navigateToCheckout(addr);
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
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 14),
            suffixIcon: suffix,
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Constants.baseColor, width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2)),
          ),
          validator: validator ??
              (v) => (v == null || v.isEmpty) ? 'This field is required' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Address',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: Colors.grey.shade700, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: Colors.grey.shade900)),
                    if (_addressList.isNotEmpty)
                      IconButton(
                        onPressed: () => setState(() => _isAddingAddress = false),
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Please enter your name';
                    if (v.trim().length < 3)
                      return 'Name must be at least 3 characters';
                    return null;
                  },
                ),
                _buildField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '9876543210',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Please enter phone number';
                    if (v.length != 10) return 'Enter valid 10-digit number';
                    return null;
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                    icon: _isFetchingLocation
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Constants.baseColor))
                        : Icon(Icons.my_location_rounded,
                            size: 18, color: Constants.baseColor),
                    label: Text(
                      _isFetchingLocation
                          ? 'Locating...'
                          : 'Use Current Location',
                      style: TextStyle(
                          color: Constants.baseColor,
                          fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Constants.baseColor.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildField(
                  controller: _pincodeController,
                  label: 'Pincode',
                  hint: '411001',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  suffix: _isPinLoading
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Constants.baseColor)),
                        )
                      : null,
                  onChanged: (v) {
                    if (v.length == 6) _fetchPincodeData(v);
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter pincode';
                    if (v.length != 6) return 'Pincode must be 6 digits';
                    return null;
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
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: Colors.grey.shade900)),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _nameController.clear();
                          _address1Controller.clear();
                          _address2Controller.clear();
                          _pincodeController.clear();
                          _cityController.clear();
                          _stateController.clear();
                          _isAddingAddress = true;
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                      label: const Text('Add New', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(foregroundColor: Constants.baseColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _addressList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final addr = _addressList[index];
                    final isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Constants.baseColor.withOpacity(0.03) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Constants.baseColor : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                              color: isSelected ? Constants.baseColor : Colors.grey.shade300,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    addr['name'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${addr['address1']}, ${addr['address2'] ?? ""}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                                  ),
                                  Text(
                                    '${addr['city']}, ${addr['state']} - ${addr['pincode']}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await AuthController.removeAddressFromList(index);
                                _loadAddresses();
                              },
                              icon: Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red.shade300),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: ElevatedButton(
          onPressed: (_selectedIndex == null && !_isAddingAddress) || _isProcessingCod ? null : _proceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.baseColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: _isProcessingCod 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Text('CONTINUE TO CHECKOUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}
