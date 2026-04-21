// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get home => 'होम';

  @override
  String get categories => 'श्रेणी';

  @override
  String get myOrders => 'माझे ऑर्डर';

  @override
  String get myCart => 'माझी कार्ट';

  @override
  String get support => 'मदत';

  @override
  String get contactUs => 'आमच्याशी संपर्क साधा';

  @override
  String get privacyPolicy => 'गोपनीयता धोरण';

  @override
  String get shippingPolicy => 'शिपिंग धोरण';

  @override
  String get termsConditions => 'नियम आणि अटी';

  @override
  String get pureOrganic => 'प्रीमियम निवड';

  @override
  String get searchProducts => 'उत्पादने शोधा...';

  @override
  String get menu => 'मेन्यू';

  @override
  String get viewCart => 'कार्ट पहा';

  @override
  String get organic => 'सेंद्रिय';

  @override
  String get bestSeller => 'सर्वात जास्त विक्री होणारे';

  @override
  String get insecticides => 'कीटकनाशके';

  @override
  String get fungicides => 'बुरशीनाशके';

  @override
  String get fertilizers => 'खते';

  @override
  String get herbicides => 'तणनाशके';

  @override
  String get growthPromotors => 'वाढ प्रवर्तक';

  @override
  String itemsAdded(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आयटम',
      one: '1 आयटम',
    );
    return '$_temp0 जोडले गेले';
  }

  @override
  String get exploreMore => 'आणखी पहा';

  @override
  String get freeShipping => 'मोफत शिपिंग';

  @override
  String get securePay => 'सुरक्षित पेमेंट';

  @override
  String get agriSupport => 'कृषी मदत';

  @override
  String get whatsAppSupport => 'व्हॉट्सॲप मदत';

  @override
  String get collection => 'संग्रह';

  @override
  String get aToZ => 'अ → ज्ञ (A → Z)';

  @override
  String get zToA => 'ज्ञ → अ (Z → A)';

  @override
  String get defaultText => 'डिफॉल्ट';

  @override
  String get pureSelection => 'Krishi Bhandar • प्रीमियम निवड';

  @override
  String get active => 'सक्रिय';

  @override
  String get noActiveOrders => 'कोणतेही सक्रिय ऑर्डर नाहीत';

  @override
  String get orderHistory => 'ऑर्डरचा इतिहास';

  @override
  String get total => 'एकूण';

  @override
  String get allOrders => 'सर्व ऑर्डर';

  @override
  String get ongoing => 'सुरू आहे';

  @override
  String get delivered => 'वितरीत';

  @override
  String get cancelled => 'रद्द केले';

  @override
  String items(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आयटम',
      one: '1 आयटम',
    );
    return '$_temp0';
  }

  @override
  String get details => 'तपशील';

  @override
  String get reorder => 'पुन्हा ऑर्डर करा';

  @override
  String get itemsAddedToBag => 'आयटम बॅगमध्ये जोडले गेले';

  @override
  String get accessRestricted => 'प्रवेश मर्यादित';

  @override
  String get signInPrompt =>
      'कृपया तुमचे ऑर्डर पाहण्यासाठी आणि तुमच्या शिपमेंटचा मागोवा घेण्यासाठी साइन इन करा.';

  @override
  String get bagEmpty => 'तुमची बॅग रिकामी आहे';

  @override
  String get emptyOrdersPrompt =>
      'असे वाटते की तुम्ही अद्याप कोणतीही ऑर्डर दिलेली नाही. खरेदी सुरू करा!';

  @override
  String get callNow => 'आता कॉल करा';

  @override
  String get helpSupport => 'मदत आणि समर्थन';

  @override
  String get supportSubtitle =>
      'आम्ही तुम्हाला कोणत्याही गोष्टीत मदत करण्यास तयार आहोत.';

  @override
  String get sendMessage => 'संदेश पाठवा';

  @override
  String get replyTime => 'आम्ही २४ तासांच्या आत उत्तर देऊ';

  @override
  String get fullName => 'पूर्ण नाव';

  @override
  String get enterName => 'तुमचे नाव प्रविष्ट करा';

  @override
  String get phoneNumber => 'फोन नंबर';

  @override
  String get enterMobile => '१०-अंकी नंबर';

  @override
  String get emailAddress => 'ईमेल पत्ता';

  @override
  String get enterEmail => 'वैध ईमेल प्रविष्ट करा';

  @override
  String get yourMessage => 'तुमचा संदेश';

  @override
  String get minCharacters => 'किमान ३ अक्षरे';

  @override
  String get sending => 'पाठवत आहे...';

  @override
  String get sendWhatsApp => 'व्हॉट्सॲपद्वारे पाठवा';

  @override
  String get headOffice => 'मुख्य कार्यालय';

  @override
  String get officeAddress => 'G-2/197A, गुलमोहर कॉलनी, भोपाळ, म.प्र., 462039';

  @override
  String get officeEmail => 'info@krishikrantiorganics.com';

  @override
  String get orderSummary => 'ऑर्डर सारांश';

  @override
  String get trackOrder => 'ऑर्डरचा मागोवा घ्या';

  @override
  String get orderPlaced => 'ऑर्डर दिली गेली';

  @override
  String get processing => 'प्रक्रिया सुरू';

  @override
  String get shipped => 'पाठवले';

  @override
  String get outForDelivery => 'वितरणासाठी बाहेर';

  @override
  String get statusUpdatedRecently => 'स्थिती नुकतीच अपडेट केली गेली';

  @override
  String get trackOnShopify => 'Shopify वर मागोवा घ्या';

  @override
  String get orderInfo => 'ऑर्डर माहिती';

  @override
  String get placedOn => 'रोजी दिली गेली';

  @override
  String get payment => 'पेमेंट';

  @override
  String get yourOrderItems => 'तुमचे ऑर्डर आयटम';

  @override
  String get billSummary => 'बिल सारांश';

  @override
  String get itemTotal => 'आयटम एकूण';

  @override
  String get deliveryCharge => 'वितरण शुल्क';

  @override
  String get handlingFee => 'हँडलिंग शुल्क';

  @override
  String get grandTotal => 'एकूण रक्कम';

  @override
  String get needHelp => 'या ऑर्डरसाठी मदत हवी आहे?';

  @override
  String paidVia(Object method) {
    return '$method द्वारे पेमेंट केले';
  }

  @override
  String get cancelOrder => 'ऑर्डर रद्द करा';

  @override
  String get cancellationReason => 'कृपया रद्द करण्याचे कारण निवडा';

  @override
  String get goBack => 'परत जा';

  @override
  String get cancelSuccess => 'ऑर्डर यशस्वीरित्या रद्द केली गेली';

  @override
  String get cancelFail =>
      'ऑर्डर रद्द करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get reasonChangedMind => 'माझा विचार बदलला';

  @override
  String get reasonMistake => 'चुकीने ऑर्डर झाली';

  @override
  String get reasonBetterPrice => 'दुसरीकडे चांगली किंमत मिळाली';

  @override
  String get reasonLongTime => 'वितरण वेळ खूप जास्त आहे';

  @override
  String get reasonCoupon => 'कूपन लावायला विसरलो';

  @override
  String get reasonOther => 'इतर';

  @override
  String get statusDeliveredMsg => 'तुमच्या दारात यशस्वीरित्या वितरित झाले.';

  @override
  String get statusShippedMsg => 'व्यापाऱ्याने कुरिअरकडे ऑर्डर सोपवली आहे.';

  @override
  String get statusProcessingMsg =>
      'ऑर्डर पॅक केली जात आहे आणि पिकअपसाठी तयार आहे.';

  @override
  String get statusCancelledMsg =>
      'तुमची ऑर्डर रद्द केली गेली आहे. परतावा प्रक्रिया केली जाईल.';

  @override
  String get statusDefaultMsg => 'उत्कृष्ट! तुमची सेवा करण्यास उत्सुक आहोत.';

  @override
  String get shopByCategory => 'श्रेणीनुसार खरेदी करा';

  @override
  String categoryCount(Object count) {
    return '$count श्रेणी';
  }

  @override
  String get premiumSelection => 'प्रीमियम निवड';

  @override
  String get appBrandName => 'Krishi Bhandar';

  @override
  String get madeWithHeartForFarmers => 'शेतकऱ्यांसाठी ❤️ सह बनवले';

  @override
  String get review1Name => 'राहुल शर्मा';

  @override
  String get review2Name => 'अमित पटेल';

  @override
  String get you => 'तुम्ही';

  @override
  String get appTagline => 'प्रत्येक शेतकऱ्याची ओळख !';

  @override
  String get updateRequired => 'अपडेट आवश्यक आहे';

  @override
  String get updateAvailable => 'अपडेट उपलब्ध आहे';

  @override
  String get forceUpdateMsg =>
      'एक महत्त्वाचे अपडेट उपलब्ध आहे. कृपया आमच्या सेवा सुरू ठेवण्यासाठी ॲप अपडेट करा.';

  @override
  String get optionalUpdateMsg =>
      'नवीन वैशिष्ट्ये आणि सुधारणांसह ॲपची नवीन आवृत्ती उपलब्ध आहे.';

  @override
  String get later => 'नंतर';

  @override
  String get updateNow => 'आता अपडेट करा';

  @override
  String get welcomeTo => 'चला सुरू करूया';

  @override
  String get loginPrompt => 'पुढे जाण्यासाठी तुमच्या मोबाईल नंबरने साइन इन करा';

  @override
  String get mobileNumber => 'मोबाईल नंबर';

  @override
  String get enterMobileValid => 'कृपया तुमचा मोबाईल नंबर प्रविष्ट करा';

  @override
  String get enterMobile10 => 'मोबाईल नंबर १० अंकी असावा';

  @override
  String tryAgainIn(Object seconds) {
    return '$seconds सेकंदात पुन्हा प्रयत्न करा';
  }

  @override
  String get sendOtp => 'ओटीपी पाठवा';

  @override
  String get verificationSentMsg => 'आम्ही तुमच्या नंबरवर पडताळणी कोड पाठवू';

  @override
  String get agreeTermsMsg => 'पुढे जाऊन, तुम्ही आमच्या ';

  @override
  String get and => ' आणि ';

  @override
  String get verifyPhone => 'तुमचा फोन नंबर\nपडताळून पहा';

  @override
  String get enterOtpPrompt => 'पाठवलेला ६-अंकी कोड प्रविष्ट करा ';

  @override
  String get verifyOtp => 'ओटीपी पडताळून पहा';

  @override
  String get resendOtpIn => 'ओटीपी पुन्हा पाठवा ';

  @override
  String get resendOtp => 'ओटीपी पुन्हा पाठवा';

  @override
  String get otpSentAgain => 'ओटीपी पुन्हा पाठवला गेला!';

  @override
  String get farmingEssentials => 'शेतीसाठी आवश्यक वस्तू';

  @override
  String get slideToDelete => 'काढून टाकण्यासाठी डावीकडे सरकवा';

  @override
  String get checkout => 'चेकआउट';

  @override
  String get cart => 'कार्ट';

  @override
  String get address => 'पत्ता';

  @override
  String get basketEmpty => 'टोकरी रिकामी आहे';

  @override
  String get basketEmptyMsg =>
      'तुमची टोकरी आमच्या शेतातील ताज्या,\nउत्कृष्ट शेती मालाची वाट पाहत आहे.';

  @override
  String get startShopping => 'खरेदी सुरू करा';

  @override
  String get pureOrganicQuality => 'प्रीमियम गुणवत्ता निवड';

  @override
  String get haveCoupon => 'कूपन कोड आहे?';

  @override
  String get couponApplied => 'कूपन लागू झाले';

  @override
  String get saveMoreMsg => 'तुमच्या ऑर्डरवर अधिक बचत करा';

  @override
  String couponAppliedMsg(Object code) {
    return '$code यशस्वीरित्या लागू झाले';
  }

  @override
  String youSaved(Object amount) {
    return 'तुम्ही या ऑर्डरवर $amount वाचवले';
  }

  @override
  String get free => 'मोफत';

  @override
  String get deliveryAddress => 'वितरण पत्ता';

  @override
  String deliveringTo(Object name) {
    return '$name ला वितरण';
  }

  @override
  String orderSuccessMsg(Object title) {
    return '$title सोबत खरेदी केल्याबद्दल धन्यवाद. तुमच्या ऑर्डरची पुष्टी झाली आहे.';
  }

  @override
  String get orderSuccessTitle => 'ऑर्डर यशस्वी';

  @override
  String get kisanSewaKendra => 'कृषि भंडार';

  @override
  String get amountPending => 'बाकी रक्कम';

  @override
  String get paymentMethod => 'पेमेंट पद्धत';

  @override
  String get cod => 'डिलिव्हरीवर रोख (COD)';

  @override
  String get onlinePayment => 'ऑनलाइन पेमेंट';

  @override
  String get confirmationEmailMsg =>
      'तुम्हाला लवकरच पुष्टीकरण ई-मेल प्राप्त होईल';

  @override
  String get continueShopping => 'खरेदी सुरू ठेवा';

  @override
  String get couponDiscount => 'कूपन सवलत';

  @override
  String get deliveryFee => 'वितरण शुल्क';

  @override
  String get change => 'बदला';

  @override
  String get orderNumber => 'ऑर्डर क्रमांक';

  @override
  String get amountPaid => 'भरलेली रक्कम';

  @override
  String get paymentId => 'पेमेंट आयडी';

  @override
  String get noProductsFound => 'या श्रेणीमध्ये कोणतीही उत्पादने आढळली नाहीत';

  @override
  String get sortBy => 'यानुसार क्रमवारी लावा';

  @override
  String get add => 'जोडा';

  @override
  String get options => 'पर्याय';

  @override
  String get selectOption => 'पर्याय निवडा';

  @override
  String get productUnavailable => 'उत्पादन तपशील सध्या उपलब्ध नाही';

  @override
  String get brand => 'ब्रँड';

  @override
  String get fastDelivery => 'वेगवान वितरण';

  @override
  String get inclusiveTaxes => 'सर्व करांसह';

  @override
  String get trust1Line1 => '100%';

  @override
  String get trust1Line2 => 'अस्सल उत्पादने';

  @override
  String get trust2Line1 => 'सुरक्षित';

  @override
  String get trust2Line2 => 'पेमेंट';

  @override
  String get trust3Line1 => 'सर्वोत्तम निकाल';

  @override
  String get trust3Line2 => 'खात्रीशीर';

  @override
  String get selectVariant => 'वैरिएंट निवडा';

  @override
  String get overview => 'आढावा';

  @override
  String get similarProducts => 'तत्सम उत्पादने';

  @override
  String get viewAll => 'सर्व पहा';

  @override
  String get addedToCart => 'उत्पादन कार्टमध्ये जोडले गेले!';

  @override
  String get easy => 'सोपे';

  @override
  String get fast => 'वेगवान';

  @override
  String get addToCart => 'कार्टमध्ये टाका';

  @override
  String get buyNow => 'आता खरेदी करा';

  @override
  String get productName => 'उत्पादनाचे नाव';

  @override
  String get category => 'श्रेणी';

  @override
  String get technicalContent => 'तांत्रिक मजकूर';

  @override
  String get noDescription => 'कोणताही तपशील उपलब्ध नाही.';

  @override
  String get aboutProduct => 'उत्पादनाबद्दल';

  @override
  String get viewMore => 'आणखी पहा';

  @override
  String get viewLess => 'कमी पहा';

  @override
  String get howToUse => 'कसे वापरावे';

  @override
  String get dosage => 'डोस';

  @override
  String get applyTime => 'वापरण्याची वेळ';

  @override
  String get method => 'पद्धत';

  @override
  String get writeReview => 'समीक्षा लिहा';

  @override
  String get shareExperience => 'या उत्पादनासह तुमचा अनुभव शेअर करा';

  @override
  String get describeExperience => 'तुमचा अनुभव सांगा...';

  @override
  String get submitReview => 'समीक्षा पाठवा';

  @override
  String get customerReviews => 'ग्राहक पुनरावलोकने';

  @override
  String get dosageDesc => '२-३ मिली प्रति लिटर पाण्यात मिसळा.';

  @override
  String get applyTimeDesc => 'सकाळी लवकर किंवा संध्याकाळी वापरणे उत्तम.';

  @override
  String get methodDesc => 'जास्तीत जास्त प्रभावीतेसाठी पानांवर फवारणी करा.';

  @override
  String get review1Comment =>
      'खूप प्रभावी उत्पादन. मला फक्त १ आठवड्यात निकाल दिसले. शिफारस करतो!';

  @override
  String get review2Comment =>
      'उत्तम दर्जा आणि अस्सल उत्पादन. पॅकेजिंग देखील खूप चांगले होते.';

  @override
  String daysAgo(Object count) {
    return '$count दिवसांपूर्वी';
  }

  @override
  String off(Object percentage) {
    return '$percentage% सवलत';
  }

  @override
  String get pgr => 'वाढ प्रवर्तक (PGR)';

  @override
  String get npkFertilizer => 'NPK खत';

  @override
  String get bioPesticide => 'जैविक कीटकनाशक';

  @override
  String get bioFungicide => 'जैविक बुरशीनाशक';

  @override
  String get bioFertilizer => 'जैविक खत';

  @override
  String get selectAddressToProceed => 'पुढे जाण्यासाठी वितरण पत्ता निवडा';

  @override
  String get addDeliveryAddress => 'वितरण पत्ता जोडा';

  @override
  String get proceedToPlaceOrder => 'ऑर्डर देण्यासाठी पुढे जा';

  @override
  String get paymentOptions => 'पेमेंट पर्याय';

  @override
  String get choosePreferredMethod => 'तुमची पसंतीची पद्धत निवडा';

  @override
  String get couponActiveOnlineDisabled => 'कूपन सक्रिय: ऑनलाइन सवलत अक्षम.';

  @override
  String get payMethodSubtitle => 'UPI, कार्ड, वॉलेट';

  @override
  String get codSubtitle => 'तुमच्या दारात पे करा';

  @override
  String get secureTransactions => '100% सुरक्षित व्यवहार';

  @override
  String get trustBadges => 'अस्सल • प्रमाणित • विश्वसनीय';

  @override
  String get applyCoupon => 'कूपन लागू करा';

  @override
  String get enterCouponCode => 'कूपन कोड प्रविष्ट करा';

  @override
  String get apply => 'लागू करा';

  @override
  String get invalidCoupon => 'अवैध किंवा मुदत संपलेला कूपन कोड.';

  @override
  String get newDeliveryAddress => 'नवीन वितरण पत्ता';

  @override
  String get firstName => 'पहिले नाव';

  @override
  String get lastName => 'आडनाव';

  @override
  String get placeholderFirstName => 'पहिले नाव';

  @override
  String get placeholderLastName => 'आडनाव';

  @override
  String get enterPhoneNumber => 'फोन नंबर प्रविष्ट करा';

  @override
  String get errPhoneRequired => 'कृपया फोन नंबर प्रविष्ट करा';

  @override
  String get errPhoneValid => 'वैध १०-अंकी नंबर प्रविष्ट करा';

  @override
  String get locating => 'शोधत आहे...';

  @override
  String get useCurrentLocation => 'सध्याचे स्थान वापरा';

  @override
  String get pincode => 'पिनकोड';

  @override
  String get addressLine1 => 'पत्ता ओळ १';

  @override
  String get addressLine1Hint => 'घर क्रमांक, गल्ली, परिसर';

  @override
  String get addressLine2 => 'पत्ता ओळ २ (पर्यायी)';

  @override
  String get addressLine2Hint => 'लँडमार्क, कॉलनी, इ.';

  @override
  String get cityDistrict => 'शहर / जिल्हा';

  @override
  String get state => 'राज्य';

  @override
  String get addNew => 'नवीन जोडा';

  @override
  String get selectAddress => 'पत्ता निवडा';

  @override
  String get saveAndConfirm => 'जतन करा आणि पुष्टी करा';

  @override
  String get confirmAddress => 'पत्त्याची पुष्टी करा';

  @override
  String get locationDisabled => 'स्थान सेवा अक्षम आहेत.';

  @override
  String get locationDenied => 'स्थान परवानग्या नाकारल्या गेल्या आहेत.';

  @override
  String get locationPermanentlyDenied =>
      'स्थान परवानग्या कायमच्या नाकारल्या गेल्या आहेत.';

  @override
  String get locationFailed => 'स्थान मिळवण्यात अयशस्वी';

  @override
  String get fieldRequired => 'हे क्षेत्र अनिवार्य आहे';

  @override
  String get placeholderCity => 'पुणे';

  @override
  String get placeholderState => 'महाराष्ट्र';

  @override
  String get placeholderPincode => '411001';

  @override
  String get clearCart => 'सर्व हटवा';

  @override
  String get clearCartConfirm => 'कार्ट रिकामी करायची?';

  @override
  String get clearCartConfirmMsg =>
      'तुम्ही खरोखर तुमच्या कार्टमधून सर्व आयटम काढू इच्छिता?';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get addFollowingToGetFree => 'Add following to get free:';
}
