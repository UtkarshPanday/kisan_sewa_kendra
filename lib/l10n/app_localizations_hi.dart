// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get home => 'होम';

  @override
  String get categories => 'श्रेणियां';

  @override
  String get myOrders => 'मेरे ऑर्डर';

  @override
  String get myCart => 'मेरी कार्ट';

  @override
  String get support => 'सहायता';

  @override
  String get contactUs => 'हमसे संपर्क करें';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get shippingPolicy => 'शिपिंग नीति';

  @override
  String get termsConditions => 'नियम और शर्तें';

  @override
  String get pureOrganic => 'प्रीमियम चयन';

  @override
  String get searchProducts => 'उत्पादों की खोज करें...';

  @override
  String get menu => 'मेन्यू';

  @override
  String get viewCart => 'कार्ट देखें';

  @override
  String get organic => 'जैविक';

  @override
  String get bestSeller => 'सबसे ज्यादा बिकने वाला';

  @override
  String get insecticides => 'कीटनाशक';

  @override
  String get fungicides => 'कवकनाशी';

  @override
  String get fertilizers => 'उर्वरक';

  @override
  String get herbicides => 'शाकनाशी';

  @override
  String get growthPromotors => 'विकास प्रवर्तक';

  @override
  String itemsAdded(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '1 आइटम',
    );
    return '$_temp0 जोड़े गए';
  }

  @override
  String get exploreMore => 'और देखें';

  @override
  String get freeShipping => 'मुफ़्त शिपिंग';

  @override
  String get securePay => 'सुरक्षित भुगतान';

  @override
  String get agriSupport => 'कृषि सहायता';

  @override
  String get whatsAppSupport => 'व्हाट्सएप सहायता';

  @override
  String get collection => 'संग्रह';

  @override
  String get aToZ => 'अ → ज्ञ (A → Z)';

  @override
  String get zToA => 'ज्ञ → अ (Z → A)';

  @override
  String get defaultText => 'डिफ़ॉल्ट';

  @override
  String get pureSelection => 'Krishi Bhandar • प्रीमियम चयन';

  @override
  String get active => 'सक्रिय';

  @override
  String get noActiveOrders => 'कोई सक्रिय ऑर्डर नहीं';

  @override
  String get orderHistory => 'ऑर्डर इतिहास';

  @override
  String get total => 'कुल';

  @override
  String get allOrders => 'सभी ऑर्डर';

  @override
  String get ongoing => 'जारी है';

  @override
  String get delivered => 'डिलिवर किया गया';

  @override
  String get cancelled => 'रद्द किया गया';

  @override
  String items(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '1 आइटम',
    );
    return '$_temp0';
  }

  @override
  String get details => 'विवरण';

  @override
  String get reorder => 'पुनः ऑर्डर करें';

  @override
  String get itemsAddedToBag => 'आइटम बैग में जोड़े गए';

  @override
  String get accessRestricted => 'पहुँच प्रतिबंधित';

  @override
  String get signInPrompt =>
      'कृपया अपने ऑर्डर देखने और वास्तविक समय में अपने शिपमेंट की प्रगति को ट्रैक करने के लिए साइन इन करें।';

  @override
  String get bagEmpty => 'आपका बैग खाली है';

  @override
  String get emptyOrdersPrompt =>
      'ऐसा लगता है कि आपने अभी तक कोई ऑर्डर नहीं दिया है। इसे भरने के लिए खरीदारी शुरू करें!';

  @override
  String get callNow => 'अभी कॉल करें';

  @override
  String get helpSupport => 'सहायता और समर्थन';

  @override
  String get supportSubtitle =>
      'हम यहां आपकी किसी भी चीज में मदद करने के लिए हैं।';

  @override
  String get sendMessage => 'एक संदेश भेजें';

  @override
  String get replyTime => 'हम 24 घंटे के भीतर जवाब देंगे';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get enterName => 'अपना नाम दर्ज करें';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get enterMobile => '10-अंकों का नंबर';

  @override
  String get emailAddress => 'ईमेल पता';

  @override
  String get enterEmail => 'वैध ईमेल दर्ज करें';

  @override
  String get yourMessage => 'आपका संदेश';

  @override
  String get minCharacters => 'न्यूनतम 3 अक्षर';

  @override
  String get sending => 'भेज रहा है...';

  @override
  String get sendWhatsApp => 'व्हाट्सएप के माध्यम से भेजें';

  @override
  String get headOffice => 'प्रधान कार्यालय';

  @override
  String get officeAddress => 'G-2/197A, गुलमोहर कॉलोनी, भोपाल, म.प्र., 462039';

  @override
  String get officeEmail => 'info@krishikrantiorganics.com';

  @override
  String get orderSummary => 'ऑर्डर सारांश';

  @override
  String get trackOrder => 'ऑर्डर ट्रैक करें';

  @override
  String get orderPlaced => 'ऑर्डर दिया गया';

  @override
  String get processing => 'प्रसंस्करण';

  @override
  String get shipped => 'शिप किया गया';

  @override
  String get outForDelivery => 'डिलिवरी के लिए बाहर';

  @override
  String get statusUpdatedRecently => 'स्थिति हाल ही में अपडेट की गई';

  @override
  String get trackOnShopify => 'Shopify पर ऑर्डर ट्रैक करें';

  @override
  String get orderInfo => 'ऑर्डर जानकारी';

  @override
  String get placedOn => 'को दिया गया';

  @override
  String get payment => 'भुगतान';

  @override
  String get yourOrderItems => 'आपके ऑर्डर आइटम';

  @override
  String get billSummary => 'बिल सारांश';

  @override
  String get itemTotal => 'आइटम कुल';

  @override
  String get deliveryCharge => 'डिलिवरी शुल्क';

  @override
  String get handlingFee => 'हैंडलिंग शुल्क';

  @override
  String get grandTotal => 'कुल योग';

  @override
  String get needHelp => 'इस ऑर्डर के लिए मदद चाहिए?';

  @override
  String paidVia(Object method) {
    return '$method के माध्यम से भुगतान किया गया';
  }

  @override
  String get cancelOrder => 'ऑर्डर रद्द करें';

  @override
  String get cancellationReason => 'कृपया रद्दीकरण का कारण चुनें';

  @override
  String get goBack => 'वापस जाएं';

  @override
  String get cancelSuccess => 'ऑर्डर सफलतापूर्वक रद्द कर दिया गया';

  @override
  String get cancelFail => 'ऑर्डर रद्द करने में विफल। कृपया पुन: प्रयास करें।';

  @override
  String get reasonChangedMind => 'मेरा विचार बदल गया';

  @override
  String get reasonMistake => 'गलती से ऑर्डर हो गया';

  @override
  String get reasonBetterPrice => 'कहीं और बेहतर कीमत मिली';

  @override
  String get reasonLongTime => 'डिलिवरी का समय बहुत लंबा है';

  @override
  String get reasonCoupon => 'कूपन लगाना भूल गए';

  @override
  String get reasonOther => 'अन्य';

  @override
  String get statusDeliveredMsg =>
      'सफलतापूर्वक आपके दरवाजे पर डिलीवर किया गया।';

  @override
  String get statusShippedMsg => 'व्यापारी ने कूरियर को ऑर्डर सौंप दिया है।';

  @override
  String get statusProcessingMsg =>
      'ऑर्डर पैक किया जा रहा है और पिकअप के लिए तैयार किया जा रहा है।';

  @override
  String get statusCancelledMsg =>
      'आपका ऑर्डर रद्द कर दिया गया था। धनवापसी संसाधित की जाएगी।';

  @override
  String get statusDefaultMsg =>
      'बहुत अच्छा! आपकी सेवा करने के लिए उत्सुक हूं।';

  @override
  String get shopByCategory => 'श्रेणी के अनुसार खरीदारी करें';

  @override
  String categoryCount(Object count) {
    return '$count श्रेणियां';
  }

  @override
  String get premiumSelection => 'प्रीमियम चयन';

  @override
  String get appBrandName => 'Krishi Bhandar';

  @override
  String get madeWithHeartForFarmers => 'किसानों के लिए ❤️ के साथ बनाया गया';

  @override
  String get review1Name => 'राहुल शर्मा';

  @override
  String get review2Name => 'अमित पटेल';

  @override
  String get you => 'आप';

  @override
  String get appTagline => 'हर किसान की पहचान !';

  @override
  String get updateRequired => 'अपडेट आवश्यक है';

  @override
  String get updateAvailable => 'अपडेट उपलब्ध है';

  @override
  String get forceUpdateMsg =>
      'एक महत्वपूर्ण अपडेट उपलब्ध है। कृपया हमारी सेवाओं का उपयोग जारी रखने के लिए ऐप को अपडेट करें।';

  @override
  String get optionalUpdateMsg =>
      'नई सुविधाओं और सुधारों के साथ ऐप का नया वर्शन उपलब्ध है।';

  @override
  String get later => 'बाद में';

  @override
  String get updateNow => 'अभी अपडेट करें';

  @override
  String get welcomeTo => 'चलिए शुरू करते हैं';

  @override
  String get loginPrompt => 'जारी रखने के लिए अपने मोबाइल नंबर से साइन इन करें';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get enterMobileValid => 'कृपया अपना मोबाइल नंबर दर्ज करें';

  @override
  String get enterMobile10 => 'मोबाइल नंबर 10 अंकों का होना चाहिए';

  @override
  String tryAgainIn(Object seconds) {
    return '$seconds सेकंड में पुन: प्रयास करें';
  }

  @override
  String get sendOtp => 'ओटीपी भेजें';

  @override
  String get verificationSentMsg => 'हम आपके नंबर पर एक सत्यापन कोड भेजेंगे';

  @override
  String get agreeTermsMsg => 'जारी रखकर, आप हमारे ';

  @override
  String get and => ' और ';

  @override
  String get verifyPhone => 'अपना फ़ोन नंबर\nसत्यापित करें';

  @override
  String get enterOtpPrompt => 'भेजे गए 6-अंकों का कोड दर्ज करें ';

  @override
  String get verifyOtp => 'ओटीपी सत्यापित करें';

  @override
  String get resendOtpIn => 'ओटीपी पुन: भेजें ';

  @override
  String get resendOtp => 'ओटीपी पुन: भेजें';

  @override
  String get otpSentAgain => 'ओटीपी फिर से भेजा गया!';

  @override
  String get farmingEssentials => 'खेती के आवश्यक सामान';

  @override
  String get slideToDelete => 'हटाने के लिए आइटम को बाईं ओर स्लाइड करें';

  @override
  String get checkout => 'चेकआउट';

  @override
  String get cart => 'कार्ट';

  @override
  String get address => 'पता';

  @override
  String get basketEmpty => 'टोकरी खाली है';

  @override
  String get basketEmptyMsg =>
      'आपकी टोकरी हमारे खेतों के ताज़ा,\nबेहतरीन खेती के सामान का इंतज़ार कर रही है।';

  @override
  String get startShopping => 'खरीदारी शुरू करें';

  @override
  String get pureOrganicQuality => 'प्रीमियम गुणवत्ता चयन';

  @override
  String get haveCoupon => 'कूपन कोड है?';

  @override
  String get couponApplied => 'कूपन लागू किया गया';

  @override
  String get saveMoreMsg => 'अपने ऑर्डर पर अधिक बचत करें';

  @override
  String couponAppliedMsg(Object code) {
    return '$code सफलतापूर्वक लागू किया गया';
  }

  @override
  String youSaved(Object amount) {
    return 'आपने इस ऑर्डर पर $amount बचाए';
  }

  @override
  String get free => 'मुफ्त';

  @override
  String get deliveryAddress => 'डिलिवरी का पता';

  @override
  String deliveringTo(Object name) {
    return '$name पर डिलीवरी';
  }

  @override
  String orderSuccessMsg(Object title) {
    return '$title के साथ खरीदारी करने के लिए धन्यवाद। आपके ऑर्डर की पुष्टि हो गई है।';
  }

  @override
  String get orderSuccessTitle => 'ऑर्डर सफल';

  @override
  String get kisanSewaKendra => 'कृषि भंडार';

  @override
  String get amountPending => 'बकाया राशि';

  @override
  String get paymentMethod => 'भुगतान विधि';

  @override
  String get cod => 'डिलीवरी पर नकद (COD)';

  @override
  String get onlinePayment => 'ऑनलाइन भुगतान';

  @override
  String get confirmationEmailMsg =>
      'आपको जल्द ही एक पुष्टिकरण ई-मेल प्राप्त होगा';

  @override
  String get continueShopping => 'खरीदारी जारी रखें';

  @override
  String get couponDiscount => 'कूपन छूट';

  @override
  String get deliveryFee => 'डिलिवरी शुल्क';

  @override
  String get change => 'बदलें';

  @override
  String get orderNumber => 'ऑर्डर संख्या';

  @override
  String get amountPaid => 'भुगतान की गई राशि';

  @override
  String get paymentId => 'भुगतान आईडी';

  @override
  String get noProductsFound => 'इस श्रेणी में कोई उत्पाद नहीं मिला';

  @override
  String get sortBy => 'इसके अनुसार क्रमबद्ध करें';

  @override
  String get add => 'जोड़ें';

  @override
  String get options => 'विकल्प';

  @override
  String get selectOption => 'विकल्प चुनें';

  @override
  String get productUnavailable => 'उत्पाद विवरण वर्तमान में उपलब्ध नहीं है';

  @override
  String get brand => 'ब्रांड';

  @override
  String get fastDelivery => 'तेज़ डिलीवरी';

  @override
  String get inclusiveTaxes => 'सभी करों सहित';

  @override
  String get trust1Line1 => '100%';

  @override
  String get trust1Line2 => 'असली उत्पाद';

  @override
  String get trust2Line1 => 'सुरक्षित';

  @override
  String get trust2Line2 => 'भुगतान';

  @override
  String get trust3Line1 => 'सर्वोत्तम परिणाम';

  @override
  String get trust3Line2 => 'गारंटीड';

  @override
  String get selectVariant => 'वैरिएंट चुनें';

  @override
  String get overview => 'अवलोकन';

  @override
  String get similarProducts => 'समान उत्पाद';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get addedToCart => 'उत्पाद कार्ट में जोड़ा गया!';

  @override
  String get easy => 'आसान';

  @override
  String get fast => 'तेज़';

  @override
  String get addToCart => 'कार्ट में डालें';

  @override
  String get buyNow => 'अभी खरीदें';

  @override
  String get productName => 'उत्पाद का नाम';

  @override
  String get category => 'श्रेणी';

  @override
  String get technicalContent => 'तकनीकी सामग्री';

  @override
  String get noDescription => 'कोई विवरण उपलब्ध नहीं है।';

  @override
  String get aboutProduct => 'उत्पाद के बारे में';

  @override
  String get viewMore => 'और देखें';

  @override
  String get viewLess => 'कम देखें';

  @override
  String get howToUse => 'उपयोग कैसे करें';

  @override
  String get dosage => 'खुराक';

  @override
  String get applyTime => 'उपयोग का समय';

  @override
  String get method => 'विधि';

  @override
  String get writeReview => 'समीक्षा लिखें';

  @override
  String get shareExperience => 'इस उत्पाद के साथ अपना अनुभव साझा करें';

  @override
  String get describeExperience => 'अपना अनुभव बताएं...';

  @override
  String get submitReview => 'समीक्षा भेजें';

  @override
  String get customerReviews => 'ग्राहक समीक्षाएं';

  @override
  String get dosageDesc => '2-3 मिली प्रति लीटर पानी में मिलाएं।';

  @override
  String get applyTimeDesc => 'सुबह जल्दी या शाम को उपयोग करना सबसे अच्छा है।';

  @override
  String get methodDesc =>
      'अत्यधिक प्रभावशीलता के लिए पत्तियों पर छिड़काव करें।';

  @override
  String get review1Comment =>
      'बहुत प्रभावी उत्पाद। मैंने मात्र 1 सप्ताह में परिणाम देखे। अत्यधिक अनुशंसित!';

  @override
  String get review2Comment =>
      'अच्छी गुणवत्ता और असली उत्पाद। पैकेजिंग भी बहुत अच्छी थी।';

  @override
  String daysAgo(Object count) {
    return '$count दिन पहले';
  }

  @override
  String off(Object percentage) {
    return '$percentage% छूट';
  }

  @override
  String get pgr => 'विकास प्रवर्तक (PGR)';

  @override
  String get npkFertilizer => 'NPK उर्वरक';

  @override
  String get bioPesticide => 'जैव कीटनाशक';

  @override
  String get bioFungicide => 'जैव कवकनाशी';

  @override
  String get bioFertilizer => 'जैव उर्वरक';

  @override
  String get selectAddressToProceed => 'आगे बढ़ने के लिए वितरण पता चुनें';

  @override
  String get addDeliveryAddress => 'वितरण पता जोड़ें';

  @override
  String get proceedToPlaceOrder => 'ऑर्डर देने के लिए आगे बढ़ें';

  @override
  String get paymentOptions => 'भुगतान विकल्प';

  @override
  String get choosePreferredMethod => 'अपनी पसंदीदा विधि चुनें';

  @override
  String get couponActiveOnlineDisabled => 'कूपन सक्रिय: ऑनलाइन छूट अक्षम।';

  @override
  String get payMethodSubtitle => 'UPI, कार्ड, वॉलेट';

  @override
  String get codSubtitle => 'अपने दरवाजे पर भुगतान करें';

  @override
  String get secureTransactions => '100% सुरक्षित लेनदेन';

  @override
  String get trustBadges => 'प्रामाणिक • प्रमाणित • विश्वसनीय';

  @override
  String get applyCoupon => 'कूपन लागू करें';

  @override
  String get enterCouponCode => 'कूपन कोड दर्ज करें';

  @override
  String get apply => 'लागू करें';

  @override
  String get invalidCoupon => 'अमान्य या समाप्त कूपन कोड।';

  @override
  String get newDeliveryAddress => 'नया वितरण पता';

  @override
  String get firstName => 'पहला नाम';

  @override
  String get lastName => 'अंतिम नाम';

  @override
  String get placeholderFirstName => 'पहला नाम';

  @override
  String get placeholderLastName => 'अंतिम नाम';

  @override
  String get enterPhoneNumber => 'फ़ोन नंबर दर्ज करें';

  @override
  String get errPhoneRequired => 'कृपया फ़ोन नंबर दर्ज करें';

  @override
  String get errPhoneValid => 'मान्य 10-अंकीय नंबर दर्ज करें';

  @override
  String get locating => 'खोज रहा है...';

  @override
  String get useCurrentLocation => 'वर्तमान स्थान का उपयोग करें';

  @override
  String get pincode => 'पिनकोड';

  @override
  String get addressLine1 => 'पता पंक्ति 1';

  @override
  String get addressLine1Hint => 'मकान नंबर, गली, क्षेत्र';

  @override
  String get addressLine2 => 'पता पंक्ति 2 (वैकल्पिक)';

  @override
  String get addressLine2Hint => 'लैंडमार्क, कॉलोनी, आदि';

  @override
  String get cityDistrict => 'शहर / जिला';

  @override
  String get state => 'राज्य';

  @override
  String get addNew => 'नया जोड़ें';

  @override
  String get selectAddress => 'पता चुनें';

  @override
  String get saveAndConfirm => 'सहेजें और पुष्टि करें';

  @override
  String get confirmAddress => 'पते की पुष्टि करें';

  @override
  String get locationDisabled => 'स्थान सेवाएं अक्षम हैं।';

  @override
  String get locationDenied => 'स्थान अनुमतियां अस्वीकार कर दी गई हैं।';

  @override
  String get locationPermanentlyDenied =>
      'स्थान अनुमतियां स्थायी रूप से अस्वीकार कर दी गई हैं।';

  @override
  String get locationFailed => 'स्थान प्राप्त करने में विफल';

  @override
  String get fieldRequired => 'यह क्षेत्र अनिवार्य है';

  @override
  String get placeholderCity => 'पुणे';

  @override
  String get placeholderState => 'महाराष्ट्र';

  @override
  String get placeholderPincode => '411001';

  @override
  String get clearCart => 'सभी हटाएं';

  @override
  String get clearCartConfirm => 'कार्ट खाली करें?';

  @override
  String get clearCartConfirmMsg =>
      'क्या आप वाकई अपनी कार्ट से सभी आइटम हटाना चाहते हैं?';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get addFollowingToGetFree => 'मुफ्त पाने के लिए निम्नलिखित जोड़ें:';
}
