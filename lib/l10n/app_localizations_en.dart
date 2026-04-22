// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get categories => 'Categories';

  @override
  String get myOrders => 'My Orders';

  @override
  String get myCart => 'My Cart';

  @override
  String get support => 'Support';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get shippingPolicy => 'Shipping Policy';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get pureOrganic => 'PURE ORGANIC';

  @override
  String get searchProducts => 'Search for products...';

  @override
  String get menu => 'MENU';

  @override
  String get viewCart => 'View Cart';

  @override
  String get organic => 'ORGANIC';

  @override
  String get bestSeller => 'Best Seller';

  @override
  String get insecticides => 'Insecticides';

  @override
  String get fungicides => 'Fungicides';

  @override
  String get fertilizers => 'Fertilizers';

  @override
  String get herbicides => 'Herbicides';

  @override
  String get growthPromotors => 'Growth Promotors';

  @override
  String itemsAdded(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0 added';
  }

  @override
  String get exploreMore => 'Explore More';

  @override
  String get freeShipping => 'Free Shipping';

  @override
  String get securePay => 'Secure Pay';

  @override
  String get agriSupport => 'Agri Support';

  @override
  String get whatsAppSupport => 'WhatsApp Support';

  @override
  String get collection => 'Collection';

  @override
  String get aToZ => 'A → Z';

  @override
  String get zToA => 'Z → A';

  @override
  String get defaultText => 'Default';

  @override
  String get pureSelection => 'Krishi Bhandar • Premium Selection';

  @override
  String get active => 'ACTIVE';

  @override
  String get noActiveOrders => 'NO ACTIVE ORDERS';

  @override
  String get orderHistory => 'Order History';

  @override
  String get total => 'TOTAL';

  @override
  String get allOrders => 'All Orders';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String items(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Items',
      one: '1 Item',
    );
    return '$_temp0';
  }

  @override
  String get details => 'Details';

  @override
  String get reorder => 'Reorder';

  @override
  String get itemsAddedToBag => 'Items added to bag';

  @override
  String get accessRestricted => 'Access Restricted';

  @override
  String get signInPrompt =>
      'Please sign in to view your orders and track the progress of your shipments in real-time.';

  @override
  String get bagEmpty => 'Your Bag is Empty';

  @override
  String get emptyOrdersPrompt =>
      'Looks like you haven\'t placed any orders yet. Start shopping to fill it up!';

  @override
  String get callNow => 'Call Now';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get supportSubtitle => 'We\'re here to help you with anything.';

  @override
  String get sendMessage => 'Send a Message';

  @override
  String get replyTime => 'We\'ll reply within 24 hours';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterName => 'Enter your name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterMobile => '10-digit number';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get enterEmail => 'Enter valid email';

  @override
  String get yourMessage => 'Your Message';

  @override
  String get minCharacters => 'Min 3 characters';

  @override
  String get sending => 'Sending...';

  @override
  String get sendWhatsApp => 'Send via WhatsApp';

  @override
  String get headOffice => 'Head Office';

  @override
  String get officeAddress => 'G-2/197A, Gulmohar Colony, Bhopal, M.P, 462039';

  @override
  String get officeEmail => 'info@krishikrantiorganics.com';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get trackOrder => 'TRACK ORDER';

  @override
  String get orderPlaced => 'Order Placed';

  @override
  String get processing => 'Processing';

  @override
  String get shipped => 'Shipped';

  @override
  String get outForDelivery => 'Out for Delivery';

  @override
  String get statusUpdatedRecently => 'Status updated recently';

  @override
  String get trackOnShopify => 'Track order on Shopify';

  @override
  String get orderInfo => 'ORDER INFO';

  @override
  String get placedOn => 'Placed on';

  @override
  String get payment => 'Payment';

  @override
  String get yourOrderItems => 'YOUR ORDER ITEMS';

  @override
  String get billSummary => 'BILL SUMMARY';

  @override
  String get itemTotal => 'Item Total';

  @override
  String get deliveryCharge => 'Delivery Charge';

  @override
  String get handlingFee => 'Handling Fee';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get needHelp => 'Need help with this order?';

  @override
  String paidVia(Object method) {
    return 'Paid via $method';
  }

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get cancellationReason => 'Please select a reason for cancellation';

  @override
  String get goBack => 'Go Back';

  @override
  String get cancelSuccess => 'Order cancelled successfully';

  @override
  String get cancelFail => 'Failed to cancel order. Please try again.';

  @override
  String get reasonChangedMind => 'Changed my mind';

  @override
  String get reasonMistake => 'Ordered by mistake';

  @override
  String get reasonBetterPrice => 'Found a better price elsewhere';

  @override
  String get reasonLongTime => 'Delivery time is too long';

  @override
  String get reasonCoupon => 'Forgot to apply coupon';

  @override
  String get reasonOther => 'Other';

  @override
  String get statusDeliveredMsg => 'Successfully delivered to your doorstep.';

  @override
  String get statusShippedMsg =>
      'Merchant has handed over the order to courier.';

  @override
  String get statusProcessingMsg =>
      'Order is being packed and prepared for pickup.';

  @override
  String get statusCancelledMsg =>
      'Your order was cancelled. Refund will be processed.';

  @override
  String get statusDefaultMsg => 'Great! Looking forward to serving you.';

  @override
  String get shopByCategory => 'Shop by Category';

  @override
  String categoryCount(Object count) {
    return '$count CATEGORIES';
  }

  @override
  String get premiumSelection => 'Premium Selection';

  @override
  String get appBrandName => 'Krishi Bhandar';

  @override
  String get madeWithHeartForFarmers => 'Made with ❤️ for Farmers';

  @override
  String get review1Name => 'Rahul Sharma';

  @override
  String get review2Name => 'Amit Patel';

  @override
  String get you => 'You';

  @override
  String get appTagline => 'Identity of every Farmer!';

  @override
  String get updateRequired => 'Update Required';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get forceUpdateMsg =>
      'A critical update is available. Please update the app to continue using our services.';

  @override
  String get optionalUpdateMsg =>
      'A new version of the app is available with new features and improvements.';

  @override
  String get later => 'LATER';

  @override
  String get updateNow => 'UPDATE NOW';

  @override
  String get welcomeTo => 'Let\'s Get Started';

  @override
  String get loginPrompt => 'Sign in with your mobile number to continue';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get enterMobileValid => 'Please enter your mobile number';

  @override
  String get enterMobile10 => 'Mobile number must be 10 digits';

  @override
  String tryAgainIn(Object seconds) {
    return 'Try again in $seconds s';
  }

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get verificationSentMsg =>
      'We\'ll send a verification code to your number';

  @override
  String get agreeTermsMsg => 'By continuing, you agree to our ';

  @override
  String get and => ' and ';

  @override
  String get verifyPhone => 'Verify your\nphone number';

  @override
  String get enterOtpPrompt => 'Enter the 6-digit code sent to ';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get resendOtpIn => 'Resend OTP in ';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get otpSentAgain => 'OTP sent again!';

  @override
  String get farmingEssentials => 'Farming Essentials';

  @override
  String get slideToDelete => 'Slide items left to quickly remove';

  @override
  String get checkout => 'Checkout';

  @override
  String get cart => 'Cart';

  @override
  String get address => 'Address';

  @override
  String get basketEmpty => 'Basket is Empty';

  @override
  String get basketEmptyMsg =>
      'Your basket is waiting for some fresh,\nquality farming essentials from our farms.';

  @override
  String get startShopping => 'START SHOPPING';

  @override
  String get pureOrganicQuality => 'Premium Quality Selection';

  @override
  String get haveCoupon => 'Have a coupon code?';

  @override
  String get couponApplied => 'Coupon Applied';

  @override
  String get saveMoreMsg => 'Save more on your order';

  @override
  String couponAppliedMsg(Object code) {
    return '$code applied successfully';
  }

  @override
  String youSaved(Object amount) {
    return 'You saved $amount on this order';
  }

  @override
  String get free => 'FREE';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String deliveringTo(Object name) {
    return 'Delivering to $name';
  }

  @override
  String orderSuccessMsg(Object title) {
    return 'Thank you for shopping with $title. Your order has been confirmed.';
  }

  @override
  String get orderSuccessTitle => 'Order Success';

  @override
  String get kisanSewaKendra => 'Krishi Bhandar';

  @override
  String get amountPending => 'Amount Pending';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cod => 'Cash on Delivery';

  @override
  String get onlinePayment => 'Online Payment';

  @override
  String get confirmationEmailMsg =>
      'You will receive a confirmation email shortly';

  @override
  String get continueShopping => 'Continue Shopping';

  @override
  String get couponDiscount => 'Coupon Discount';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get change => 'CHANGE';

  @override
  String get orderNumber => 'Order Number';

  @override
  String get amountPaid => 'Amount Paid';

  @override
  String get paymentId => 'Payment ID';

  @override
  String get noProductsFound => 'No products found in this category';

  @override
  String get sortBy => 'Sort By';

  @override
  String get add => 'ADD';

  @override
  String get options => 'Options';

  @override
  String get selectOption => 'Select Option';

  @override
  String get productUnavailable => 'Product details currently unavailable';

  @override
  String get brand => 'Brand';

  @override
  String get fastDelivery => 'Fast Delivery';

  @override
  String get inclusiveTaxes => 'Inclusive of all taxes';

  @override
  String get trust1Line1 => '100%';

  @override
  String get trust1Line2 => 'Original Products';

  @override
  String get trust2Line1 => 'Secure';

  @override
  String get trust2Line2 => 'Payments';

  @override
  String get trust3Line1 => 'Best Results';

  @override
  String get trust3Line2 => 'Guaranteed';

  @override
  String get selectVariant => 'Select Variant';

  @override
  String get overview => 'OVERVIEW';

  @override
  String get similarProducts => 'Similar Products';

  @override
  String get viewAll => 'View All';

  @override
  String get addedToCart => 'Product added to cart!';

  @override
  String get easy => 'Easy';

  @override
  String get fast => 'Fast';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get productName => 'Product Name';

  @override
  String get category => 'Category';

  @override
  String get technicalContent => 'Technical Content';

  @override
  String get noDescription => 'No description available.';

  @override
  String get aboutProduct => 'About Product';

  @override
  String get viewMore => 'VIEW MORE';

  @override
  String get viewLess => 'VIEW LESS';

  @override
  String get howToUse => 'How to Use';

  @override
  String get dosage => 'Dosage';

  @override
  String get applyTime => 'Apply Time';

  @override
  String get method => 'Method';

  @override
  String get writeReview => 'Write a Review';

  @override
  String get shareExperience => 'Share your experience with this product';

  @override
  String get describeExperience => 'Describe your experience...';

  @override
  String get submitReview => 'SUBMIT REVIEW';

  @override
  String get customerReviews => 'Customer Reviews';

  @override
  String get dosageDesc => 'Mix 2-3 ml per liter of water.';

  @override
  String get applyTimeDesc => 'Best applied during early morning or evening.';

  @override
  String get methodDesc => 'Foliar spray for maximum effectiveness.';

  @override
  String get review1Comment =>
      'Very effective product. I saw results in just 1 week. Highly recommended!';

  @override
  String get review2Comment =>
      'Good quality and original product. Packaging was also very good.';

  @override
  String daysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String off(Object percentage) {
    return '$percentage% OFF';
  }

  @override
  String get pgr => 'PGRs';

  @override
  String get npkFertilizer => 'NPK Fertilizers';

  @override
  String get bioPesticide => 'Bio-Pesticides';

  @override
  String get bioFungicide => 'Bio-Fungicide';

  @override
  String get bioFertilizer => 'Bio-Fertilizers';

  @override
  String get selectAddressToProceed => 'Select delivery address to proceed';

  @override
  String get addDeliveryAddress => 'ADD DELIVERY ADDRESS';

  @override
  String get proceedToPlaceOrder => 'PROCEED TO PLACE ORDER';

  @override
  String get paymentOptions => 'Payment Options';

  @override
  String get choosePreferredMethod => 'Choose your preferred method';

  @override
  String get couponActiveOnlineDisabled =>
      'Coupon active: Online discount disabled.';

  @override
  String get payMethodSubtitle => 'UPI, Cards, Wallets';

  @override
  String get codSubtitle => 'Pay at your doorstep';

  @override
  String get secureTransactions => '100% SECURE TRANSACTIONS';

  @override
  String get trustBadges => 'AUTHENTIC • CERTIFIED • RELIABLE';

  @override
  String get applyCoupon => 'Apply Coupon';

  @override
  String get enterCouponCode => 'Enter coupon code';

  @override
  String get apply => 'APPLY';

  @override
  String get invalidCoupon => 'Invalid or expired coupon code.';

  @override
  String get newDeliveryAddress => 'New Delivery Address';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get placeholderFirstName => 'John';

  @override
  String get placeholderLastName => 'Doe';

  @override
  String get enterPhoneNumber => 'Enter Phone Number';

  @override
  String get errPhoneRequired => 'Please enter phone number';

  @override
  String get errPhoneValid => 'Enter valid 10-digit number';

  @override
  String get locating => 'Locating...';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get pincode => 'Pincode';

  @override
  String get addressLine1 => 'Address Line 1';

  @override
  String get addressLine1Hint => 'House no., Street, Area';

  @override
  String get addressLine2 => 'Address Line 2 (Optional)';

  @override
  String get addressLine2Hint => 'Landmark, Colony, etc.';

  @override
  String get cityDistrict => 'City / District';

  @override
  String get state => 'State';

  @override
  String get addNew => 'Add New';

  @override
  String get selectAddress => 'Select Address';

  @override
  String get saveAndConfirm => 'SAVE & CONFIRM';

  @override
  String get confirmAddress => 'CONFIRM ADDRESS';

  @override
  String get locationDisabled => 'Location services are disabled.';

  @override
  String get locationDenied => 'Location permissions are denied.';

  @override
  String get locationPermanentlyDenied =>
      'Location permissions are permanently denied.';

  @override
  String get locationFailed => 'Failed to get location';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get placeholderCity => 'Pune';

  @override
  String get placeholderState => 'Maharashtra';

  @override
  String get placeholderPincode => '411001';

  @override
  String get clearCart => 'Clear All';

  @override
  String get clearCartConfirm => 'Clear Cart?';

  @override
  String get clearCartConfirmMsg =>
      'Are you sure you want to remove all items from your cart?';

  @override
  String get cancel => 'CANCEL';

  @override
  String get addFollowingToGetFree => 'Add following to get free:';
}
