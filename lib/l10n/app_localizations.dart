import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
    Locale('ta'),
    Locale('te')
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @shippingPolicy.
  ///
  /// In en, this message translates to:
  /// **'Shipping Policy'**
  String get shippingPolicy;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @pureOrganic.
  ///
  /// In en, this message translates to:
  /// **'PURE ORGANIC'**
  String get pureOrganic;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search for products...'**
  String get searchProducts;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'MENU'**
  String get menu;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// No description provided for @organic.
  ///
  /// In en, this message translates to:
  /// **'ORGANIC'**
  String get organic;

  /// No description provided for @bestSeller.
  ///
  /// In en, this message translates to:
  /// **'Best Seller'**
  String get bestSeller;

  /// No description provided for @insecticides.
  ///
  /// In en, this message translates to:
  /// **'Insecticides'**
  String get insecticides;

  /// No description provided for @fungicides.
  ///
  /// In en, this message translates to:
  /// **'Fungicides'**
  String get fungicides;

  /// No description provided for @fertilizers.
  ///
  /// In en, this message translates to:
  /// **'Fertilizers'**
  String get fertilizers;

  /// No description provided for @herbicides.
  ///
  /// In en, this message translates to:
  /// **'Herbicides'**
  String get herbicides;

  /// No description provided for @growthPromotors.
  ///
  /// In en, this message translates to:
  /// **'Growth Promotors'**
  String get growthPromotors;

  /// No description provided for @itemsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}} added'**
  String itemsAdded(num count);

  /// No description provided for @exploreMore.
  ///
  /// In en, this message translates to:
  /// **'Explore More'**
  String get exploreMore;

  /// No description provided for @freeShipping.
  ///
  /// In en, this message translates to:
  /// **'Free Shipping'**
  String get freeShipping;

  /// No description provided for @securePay.
  ///
  /// In en, this message translates to:
  /// **'Secure Pay'**
  String get securePay;

  /// No description provided for @agriSupport.
  ///
  /// In en, this message translates to:
  /// **'Agri Support'**
  String get agriSupport;

  /// No description provided for @whatsAppSupport.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get whatsAppSupport;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// No description provided for @aToZ.
  ///
  /// In en, this message translates to:
  /// **'A → Z'**
  String get aToZ;

  /// No description provided for @zToA.
  ///
  /// In en, this message translates to:
  /// **'Z → A'**
  String get zToA;

  /// No description provided for @defaultText.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultText;

  /// No description provided for @pureSelection.
  ///
  /// In en, this message translates to:
  /// **'Krishi Bhandar • Premium Selection'**
  String get pureSelection;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @noActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'NO ACTIVE ORDERS'**
  String get noActiveOrders;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @allOrders.
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get allOrders;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Item} other{{count} Items}}'**
  String items(num count);

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @itemsAddedToBag.
  ///
  /// In en, this message translates to:
  /// **'Items added to bag'**
  String get itemsAddedToBag;

  /// No description provided for @accessRestricted.
  ///
  /// In en, this message translates to:
  /// **'Access Restricted'**
  String get accessRestricted;

  /// No description provided for @signInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view your orders and track the progress of your shipments in real-time.'**
  String get signInPrompt;

  /// No description provided for @bagEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your Bag is Empty'**
  String get bagEmpty;

  /// No description provided for @emptyOrdersPrompt.
  ///
  /// In en, this message translates to:
  /// **'Looks like you haven\'t placed any orders yet. Start shopping to fill it up!'**
  String get emptyOrdersPrompt;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callNow;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @supportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help you with anything.'**
  String get supportSubtitle;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a Message'**
  String get sendMessage;

  /// No description provided for @replyTime.
  ///
  /// In en, this message translates to:
  /// **'We\'ll reply within 24 hours'**
  String get replyTime;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterMobile.
  ///
  /// In en, this message translates to:
  /// **'10-digit number'**
  String get enterMobile;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email'**
  String get enterEmail;

  /// No description provided for @yourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Message'**
  String get yourMessage;

  /// No description provided for @minCharacters.
  ///
  /// In en, this message translates to:
  /// **'Min 3 characters'**
  String get minCharacters;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @sendWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Send via WhatsApp'**
  String get sendWhatsApp;

  /// No description provided for @headOffice.
  ///
  /// In en, this message translates to:
  /// **'Head Office'**
  String get headOffice;

  /// No description provided for @officeAddress.
  ///
  /// In en, this message translates to:
  /// **'G-2/197A, Gulmohar Colony, Bhopal, M.P, 462039'**
  String get officeAddress;

  /// No description provided for @officeEmail.
  ///
  /// In en, this message translates to:
  /// **'info@krishikrantiorganics.com'**
  String get officeEmail;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'TRACK ORDER'**
  String get trackOrder;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderPlaced;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shipped;

  /// No description provided for @outForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get outForDelivery;

  /// No description provided for @statusUpdatedRecently.
  ///
  /// In en, this message translates to:
  /// **'Status updated recently'**
  String get statusUpdatedRecently;

  /// No description provided for @trackOnShopify.
  ///
  /// In en, this message translates to:
  /// **'Track order on Shopify'**
  String get trackOnShopify;

  /// No description provided for @orderInfo.
  ///
  /// In en, this message translates to:
  /// **'ORDER INFO'**
  String get orderInfo;

  /// No description provided for @placedOn.
  ///
  /// In en, this message translates to:
  /// **'Placed on'**
  String get placedOn;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @yourOrderItems.
  ///
  /// In en, this message translates to:
  /// **'YOUR ORDER ITEMS'**
  String get yourOrderItems;

  /// No description provided for @billSummary.
  ///
  /// In en, this message translates to:
  /// **'BILL SUMMARY'**
  String get billSummary;

  /// No description provided for @itemTotal.
  ///
  /// In en, this message translates to:
  /// **'Item Total'**
  String get itemTotal;

  /// No description provided for @deliveryCharge.
  ///
  /// In en, this message translates to:
  /// **'Delivery Charge'**
  String get deliveryCharge;

  /// No description provided for @handlingFee.
  ///
  /// In en, this message translates to:
  /// **'Handling Fee'**
  String get handlingFee;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help with this order?'**
  String get needHelp;

  /// No description provided for @paidVia.
  ///
  /// In en, this message translates to:
  /// **'Paid via {method}'**
  String paidVia(Object method);

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @cancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for cancellation'**
  String get cancellationReason;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @cancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled successfully'**
  String get cancelSuccess;

  /// No description provided for @cancelFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel order. Please try again.'**
  String get cancelFail;

  /// No description provided for @reasonChangedMind.
  ///
  /// In en, this message translates to:
  /// **'Changed my mind'**
  String get reasonChangedMind;

  /// No description provided for @reasonMistake.
  ///
  /// In en, this message translates to:
  /// **'Ordered by mistake'**
  String get reasonMistake;

  /// No description provided for @reasonBetterPrice.
  ///
  /// In en, this message translates to:
  /// **'Found a better price elsewhere'**
  String get reasonBetterPrice;

  /// No description provided for @reasonLongTime.
  ///
  /// In en, this message translates to:
  /// **'Delivery time is too long'**
  String get reasonLongTime;

  /// No description provided for @reasonCoupon.
  ///
  /// In en, this message translates to:
  /// **'Forgot to apply coupon'**
  String get reasonCoupon;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @statusDeliveredMsg.
  ///
  /// In en, this message translates to:
  /// **'Successfully delivered to your doorstep.'**
  String get statusDeliveredMsg;

  /// No description provided for @statusShippedMsg.
  ///
  /// In en, this message translates to:
  /// **'Merchant has handed over the order to courier.'**
  String get statusShippedMsg;

  /// No description provided for @statusProcessingMsg.
  ///
  /// In en, this message translates to:
  /// **'Order is being packed and prepared for pickup.'**
  String get statusProcessingMsg;

  /// No description provided for @statusCancelledMsg.
  ///
  /// In en, this message translates to:
  /// **'Your order was cancelled. Refund will be processed.'**
  String get statusCancelledMsg;

  /// No description provided for @statusDefaultMsg.
  ///
  /// In en, this message translates to:
  /// **'Great! Looking forward to serving you.'**
  String get statusDefaultMsg;

  /// No description provided for @shopByCategory.
  ///
  /// In en, this message translates to:
  /// **'Shop by Category'**
  String get shopByCategory;

  /// No description provided for @categoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} CATEGORIES'**
  String categoryCount(Object count);

  /// No description provided for @premiumSelection.
  ///
  /// In en, this message translates to:
  /// **'Premium Selection'**
  String get premiumSelection;

  /// No description provided for @appBrandName.
  ///
  /// In en, this message translates to:
  /// **'Krishi Bhandar'**
  String get appBrandName;

  /// No description provided for @madeWithHeartForFarmers.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ for Farmers'**
  String get madeWithHeartForFarmers;

  /// No description provided for @review1Name.
  ///
  /// In en, this message translates to:
  /// **'Rahul Sharma'**
  String get review1Name;

  /// No description provided for @review2Name.
  ///
  /// In en, this message translates to:
  /// **'Amit Patel'**
  String get review2Name;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Identity of every Farmer!'**
  String get appTagline;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequired;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @forceUpdateMsg.
  ///
  /// In en, this message translates to:
  /// **'A critical update is available. Please update the app to continue using our services.'**
  String get forceUpdateMsg;

  /// No description provided for @optionalUpdateMsg.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available with new features and improvements.'**
  String get optionalUpdateMsg;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'LATER'**
  String get later;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'UPDATE NOW'**
  String get updateNow;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get Started'**
  String get welcomeTo;

  /// No description provided for @loginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number to continue'**
  String get loginPrompt;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @enterMobileValid.
  ///
  /// In en, this message translates to:
  /// **'Please enter your mobile number'**
  String get enterMobileValid;

  /// No description provided for @enterMobile10.
  ///
  /// In en, this message translates to:
  /// **'Mobile number must be 10 digits'**
  String get enterMobile10;

  /// No description provided for @tryAgainIn.
  ///
  /// In en, this message translates to:
  /// **'Try again in {seconds} s'**
  String tryAgainIn(Object seconds);

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verificationSentMsg.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification code to your number'**
  String get verificationSentMsg;

  /// No description provided for @agreeTermsMsg.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get agreeTermsMsg;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @verifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify your\nphone number'**
  String get verifyPhone;

  /// No description provided for @enterOtpPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to '**
  String get enterOtpPrompt;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @resendOtpIn.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in '**
  String get resendOtpIn;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @otpSentAgain.
  ///
  /// In en, this message translates to:
  /// **'OTP sent again!'**
  String get otpSentAgain;

  /// No description provided for @farmingEssentials.
  ///
  /// In en, this message translates to:
  /// **'Farming Essentials'**
  String get farmingEssentials;

  /// No description provided for @slideToDelete.
  ///
  /// In en, this message translates to:
  /// **'Slide items left to quickly remove'**
  String get slideToDelete;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @basketEmpty.
  ///
  /// In en, this message translates to:
  /// **'Basket is Empty'**
  String get basketEmpty;

  /// No description provided for @basketEmptyMsg.
  ///
  /// In en, this message translates to:
  /// **'Your basket is waiting for some fresh,\nquality farming essentials from our farms.'**
  String get basketEmptyMsg;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'START SHOPPING'**
  String get startShopping;

  /// No description provided for @pureOrganicQuality.
  ///
  /// In en, this message translates to:
  /// **'Premium Quality Selection'**
  String get pureOrganicQuality;

  /// No description provided for @haveCoupon.
  ///
  /// In en, this message translates to:
  /// **'Have a coupon code?'**
  String get haveCoupon;

  /// No description provided for @couponApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon Applied'**
  String get couponApplied;

  /// No description provided for @saveMoreMsg.
  ///
  /// In en, this message translates to:
  /// **'Save more on your order'**
  String get saveMoreMsg;

  /// No description provided for @couponAppliedMsg.
  ///
  /// In en, this message translates to:
  /// **'{code} applied successfully'**
  String couponAppliedMsg(Object code);

  /// No description provided for @youSaved.
  ///
  /// In en, this message translates to:
  /// **'You saved {amount} on this order'**
  String youSaved(Object amount);

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @deliveringTo.
  ///
  /// In en, this message translates to:
  /// **'Delivering to {name}'**
  String deliveringTo(Object name);

  /// No description provided for @orderSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Thank you for shopping with {title}. Your order has been confirmed.'**
  String orderSuccessMsg(Object title);

  /// No description provided for @orderSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Success'**
  String get orderSuccessTitle;

  /// No description provided for @kisanSewaKendra.
  ///
  /// In en, this message translates to:
  /// **'Krishi Bhandar'**
  String get kisanSewaKendra;

  /// No description provided for @amountPending.
  ///
  /// In en, this message translates to:
  /// **'Amount Pending'**
  String get amountPending;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @cod.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cod;

  /// No description provided for @onlinePayment.
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get onlinePayment;

  /// No description provided for @confirmationEmailMsg.
  ///
  /// In en, this message translates to:
  /// **'You will receive a confirmation email shortly'**
  String get confirmationEmailMsg;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @couponDiscount.
  ///
  /// In en, this message translates to:
  /// **'Coupon Discount'**
  String get couponDiscount;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get change;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get orderNumber;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;

  /// No description provided for @paymentId.
  ///
  /// In en, this message translates to:
  /// **'Payment ID'**
  String get paymentId;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found in this category'**
  String get noProductsFound;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get add;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'Select Option'**
  String get selectOption;

  /// No description provided for @productUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Product details currently unavailable'**
  String get productUnavailable;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @fastDelivery.
  ///
  /// In en, this message translates to:
  /// **'Fast Delivery'**
  String get fastDelivery;

  /// No description provided for @inclusiveTaxes.
  ///
  /// In en, this message translates to:
  /// **'Inclusive of all taxes'**
  String get inclusiveTaxes;

  /// No description provided for @trust1Line1.
  ///
  /// In en, this message translates to:
  /// **'100%'**
  String get trust1Line1;

  /// No description provided for @trust1Line2.
  ///
  /// In en, this message translates to:
  /// **'Original Products'**
  String get trust1Line2;

  /// No description provided for @trust2Line1.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get trust2Line1;

  /// No description provided for @trust2Line2.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get trust2Line2;

  /// No description provided for @trust3Line1.
  ///
  /// In en, this message translates to:
  /// **'Best Results'**
  String get trust3Line1;

  /// No description provided for @trust3Line2.
  ///
  /// In en, this message translates to:
  /// **'Guaranteed'**
  String get trust3Line2;

  /// No description provided for @selectVariant.
  ///
  /// In en, this message translates to:
  /// **'Select Variant'**
  String get selectVariant;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'OVERVIEW'**
  String get overview;

  /// No description provided for @similarProducts.
  ///
  /// In en, this message translates to:
  /// **'Similar Products'**
  String get similarProducts;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Product added to cart!'**
  String get addedToCart;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @technicalContent.
  ///
  /// In en, this message translates to:
  /// **'Technical Content'**
  String get technicalContent;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescription;

  /// No description provided for @aboutProduct.
  ///
  /// In en, this message translates to:
  /// **'About Product'**
  String get aboutProduct;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'VIEW MORE'**
  String get viewMore;

  /// No description provided for @viewLess.
  ///
  /// In en, this message translates to:
  /// **'VIEW LESS'**
  String get viewLess;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get howToUse;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @applyTime.
  ///
  /// In en, this message translates to:
  /// **'Apply Time'**
  String get applyTime;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @shareExperience.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this product'**
  String get shareExperience;

  /// No description provided for @describeExperience.
  ///
  /// In en, this message translates to:
  /// **'Describe your experience...'**
  String get describeExperience;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT REVIEW'**
  String get submitReview;

  /// No description provided for @customerReviews.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get customerReviews;

  /// No description provided for @dosageDesc.
  ///
  /// In en, this message translates to:
  /// **'Mix 2-3 ml per liter of water.'**
  String get dosageDesc;

  /// No description provided for @applyTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Best applied during early morning or evening.'**
  String get applyTimeDesc;

  /// No description provided for @methodDesc.
  ///
  /// In en, this message translates to:
  /// **'Foliar spray for maximum effectiveness.'**
  String get methodDesc;

  /// No description provided for @review1Comment.
  ///
  /// In en, this message translates to:
  /// **'Very effective product. I saw results in just 1 week. Highly recommended!'**
  String get review1Comment;

  /// No description provided for @review2Comment.
  ///
  /// In en, this message translates to:
  /// **'Good quality and original product. Packaging was also very good.'**
  String get review2Comment;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(Object count);

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% OFF'**
  String off(Object percentage);

  /// No description provided for @pgr.
  ///
  /// In en, this message translates to:
  /// **'PGRs'**
  String get pgr;

  /// No description provided for @npkFertilizer.
  ///
  /// In en, this message translates to:
  /// **'NPK Fertilizers'**
  String get npkFertilizer;

  /// No description provided for @bioPesticide.
  ///
  /// In en, this message translates to:
  /// **'Bio-Pesticides'**
  String get bioPesticide;

  /// No description provided for @bioFungicide.
  ///
  /// In en, this message translates to:
  /// **'Bio-Fungicide'**
  String get bioFungicide;

  /// No description provided for @bioFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Bio-Fertilizers'**
  String get bioFertilizer;

  /// No description provided for @selectAddressToProceed.
  ///
  /// In en, this message translates to:
  /// **'Select delivery address to proceed'**
  String get selectAddressToProceed;

  /// No description provided for @addDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'ADD DELIVERY ADDRESS'**
  String get addDeliveryAddress;

  /// No description provided for @proceedToPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'PROCEED TO PLACE ORDER'**
  String get proceedToPlaceOrder;

  /// No description provided for @paymentOptions.
  ///
  /// In en, this message translates to:
  /// **'Payment Options'**
  String get paymentOptions;

  /// No description provided for @choosePreferredMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred method'**
  String get choosePreferredMethod;

  /// No description provided for @couponActiveOnlineDisabled.
  ///
  /// In en, this message translates to:
  /// **'Coupon active: Online discount disabled.'**
  String get couponActiveOnlineDisabled;

  /// No description provided for @payMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'UPI, Cards, Wallets'**
  String get payMethodSubtitle;

  /// No description provided for @codSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay at your doorstep'**
  String get codSubtitle;

  /// No description provided for @secureTransactions.
  ///
  /// In en, this message translates to:
  /// **'100% SECURE TRANSACTIONS'**
  String get secureTransactions;

  /// No description provided for @trustBadges.
  ///
  /// In en, this message translates to:
  /// **'AUTHENTIC • CERTIFIED • RELIABLE'**
  String get trustBadges;

  /// No description provided for @applyCoupon.
  ///
  /// In en, this message translates to:
  /// **'Apply Coupon'**
  String get applyCoupon;

  /// No description provided for @enterCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code'**
  String get enterCouponCode;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get apply;

  /// No description provided for @invalidCoupon.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired coupon code.'**
  String get invalidCoupon;

  /// No description provided for @newDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'New Delivery Address'**
  String get newDeliveryAddress;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @placeholderFirstName.
  ///
  /// In en, this message translates to:
  /// **'John'**
  String get placeholderFirstName;

  /// No description provided for @placeholderLastName.
  ///
  /// In en, this message translates to:
  /// **'Doe'**
  String get placeholderLastName;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Phone Number'**
  String get enterPhoneNumber;

  /// No description provided for @errPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get errPhoneRequired;

  /// No description provided for @errPhoneValid.
  ///
  /// In en, this message translates to:
  /// **'Enter valid 10-digit number'**
  String get errPhoneValid;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Locating...'**
  String get locating;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincode;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address Line 1'**
  String get addressLine1;

  /// No description provided for @addressLine1Hint.
  ///
  /// In en, this message translates to:
  /// **'House no., Street, Area'**
  String get addressLine1Hint;

  /// No description provided for @addressLine2.
  ///
  /// In en, this message translates to:
  /// **'Address Line 2 (Optional)'**
  String get addressLine2;

  /// No description provided for @addressLine2Hint.
  ///
  /// In en, this message translates to:
  /// **'Landmark, Colony, etc.'**
  String get addressLine2Hint;

  /// No description provided for @cityDistrict.
  ///
  /// In en, this message translates to:
  /// **'City / District'**
  String get cityDistrict;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @selectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select Address'**
  String get selectAddress;

  /// No description provided for @saveAndConfirm.
  ///
  /// In en, this message translates to:
  /// **'SAVE & CONFIRM'**
  String get saveAndConfirm;

  /// No description provided for @confirmAddress.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM ADDRESS'**
  String get confirmAddress;

  /// No description provided for @locationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationDisabled;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied.'**
  String get locationDenied;

  /// No description provided for @locationPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied.'**
  String get locationPermanentlyDenied;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get location'**
  String get locationFailed;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @placeholderCity.
  ///
  /// In en, this message translates to:
  /// **'Pune'**
  String get placeholderCity;

  /// No description provided for @placeholderState.
  ///
  /// In en, this message translates to:
  /// **'Maharashtra'**
  String get placeholderState;

  /// No description provided for @placeholderPincode.
  ///
  /// In en, this message translates to:
  /// **'411001'**
  String get placeholderPincode;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearCart;

  /// No description provided for @clearCartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart?'**
  String get clearCartConfirm;

  /// No description provided for @clearCartConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all items from your cart?'**
  String get clearCartConfirmMsg;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @addFollowingToGetFree.
  ///
  /// In en, this message translates to:
  /// **'Add following to get free:'**
  String get addFollowingToGetFree;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr', 'ta', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
