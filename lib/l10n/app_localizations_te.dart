// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get home => 'హోమ్';

  @override
  String get categories => 'వర్గాలు';

  @override
  String get myOrders => 'నా ఆర్డర్లు';

  @override
  String get myCart => 'నా కార్ట్';

  @override
  String get support => 'మద్దతు';

  @override
  String get contactUs => 'మమ్మల్ని సంప్రదించండి';

  @override
  String get privacyPolicy => 'గోప్యతా విధానం';

  @override
  String get shippingPolicy => 'షిప్పింగ్ విధానం';

  @override
  String get termsConditions => 'నిబంధనలు & షరతులు';

  @override
  String get pureOrganic => 'స్వచ్ఛమైన సేంద్రియ';

  @override
  String get searchProducts => 'ఉత్పత్తుల కోసం వెతకండి...';

  @override
  String get menu => 'మెనూ';

  @override
  String get viewCart => 'కార్ట్‌ను చూడండి';

  @override
  String get organic => 'సేంద్రియ';

  @override
  String get bestSeller => 'బెస్ట్ సెల్లర్';

  @override
  String get insecticides => 'కీటక సంహారిణులు';

  @override
  String get fungicides => 'శిలీంధ్ర సంహారిణులు';

  @override
  String get fertilizers => 'ఎరువులు';

  @override
  String get herbicides => 'కలుపు సంహారిణులు';

  @override
  String get growthPromotors => 'పెరుగుదల ప్రోత్సాహకాలు';

  @override
  String itemsAdded(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count వస్తువులు',
      one: '1 వస్తువు',
    );
    return '$_temp0 జోడించబడ్డాయి';
  }

  @override
  String get exploreMore => 'మరిన్ని అన్వేషించండి';

  @override
  String get freeShipping => 'ఉచిత షిప్పింగ్';

  @override
  String get securePay => 'సురక్షిత చెల్లింపు';

  @override
  String get agriSupport => 'వ్యవసాయ మద్దతు';

  @override
  String get whatsAppSupport => 'వాట్సాప్ మద్దతు';

  @override
  String get collection => 'సేకరణ';

  @override
  String get aToZ => 'అ → క్ష (A → Z)';

  @override
  String get zToA => 'క్ష → అ (Z → A)';

  @override
  String get defaultText => 'డిఫాల్ట్';

  @override
  String get pureSelection => 'Krishi Bhandar • ప్రీమియం ఎంపిక';

  @override
  String get active => 'క్రియాశీలం';

  @override
  String get noActiveOrders => 'క్రియాశీల ఆర్డర్లు లేవు';

  @override
  String get orderHistory => 'ఆర్డర్ చరిత్ర';

  @override
  String get total => 'మొత్తం';

  @override
  String get allOrders => 'అన్ని ఆర్డర్లు';

  @override
  String get ongoing => 'కొనసాగుతోంది';

  @override
  String get delivered => 'డెలివరీ చేయబడింది';

  @override
  String get cancelled => 'రద్దు చేయబడింది';

  @override
  String items(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count వస్తువులు',
      one: '1 వస్తువు',
    );
    return '$_temp0';
  }

  @override
  String get details => 'వివరాలు';

  @override
  String get reorder => 'మళ్లీ ఆర్డర్ చేయండి';

  @override
  String get itemsAddedToBag => 'వస్తువులు బ్యాగ్‌లో జోడించబడ్డాయి';

  @override
  String get accessRestricted => 'ప్రాప్యత పరిమితం చేయబడింది';

  @override
  String get signInPrompt =>
      'మీ ఆర్డర్‌లను చూడటానికి మరియు నిజ సమయంలో ట్రాక్ చేయడానికి దయచేసి సైన్ ఇన్ చేయండి.';

  @override
  String get bagEmpty => 'మీ బ్యాగ్ ఖాళీగా ఉంది';

  @override
  String get emptyOrdersPrompt =>
      'మీరు ఇంకా ఎటువంటి ఆర్డర్లు చేసినట్లు లేదు. షాపింగ్ ప్రారంభించండి!';

  @override
  String get callNow => 'ఇప్పుడే కాల్ చేయండి';

  @override
  String get helpSupport => 'సహాయం & మద్దతు';

  @override
  String get supportSubtitle =>
      'మీకు దేనికైనా సహాయం చేయడానికి మేము ఇక్కడ ఉన్నాము.';

  @override
  String get sendMessage => 'సందేశం పంపండి';

  @override
  String get replyTime => 'మేము 24 గంటల్లోపు సమాధానం ఇస్తాము';

  @override
  String get fullName => 'పూర్తి పేరు';

  @override
  String get enterName => 'మీ పేరును నమోదు చేయండి';

  @override
  String get phoneNumber => 'ఫోన్ నంబర్';

  @override
  String get enterMobile => '10-అంకెల సంఖ్య';

  @override
  String get emailAddress => 'ఇమెయిల్ చిరునామా';

  @override
  String get enterEmail => 'చెల్లుబాటు అయ్యే ఇమెయిల్ నమోదు చేయండి';

  @override
  String get yourMessage => 'మీ సందేశం';

  @override
  String get minCharacters => 'కనిష్టంగా 3 అక్షరాలు';

  @override
  String get sending => 'పంపుతోంది...';

  @override
  String get sendWhatsApp => 'వాట్సాప్ ద్వారా పంపండి';

  @override
  String get headOffice => 'ప్రధాన కార్యాలయం';

  @override
  String get officeAddress => 'G-2/197A, గుల్మోహర్ కాలనీ, భోపాల్, M.P, 462039';

  @override
  String get officeEmail => 'info@krishikrantiorganics.com';

  @override
  String get orderSummary => 'ఆర్డర్ సారాంశం';

  @override
  String get trackOrder => 'ఆర్డర్ ట్రాక్ చేయండి';

  @override
  String get orderPlaced => 'ఆర్డర్ చేయబడింది';

  @override
  String get processing => 'ప్రాసెసింగ్';

  @override
  String get shipped => 'షిప్ చేయబడింది';

  @override
  String get outForDelivery => 'డెలివరీకి సిద్ధంగా ఉంది';

  @override
  String get statusUpdatedRecently => 'స్థితి ఇటీవల నవీకరించబడింది';

  @override
  String get trackOnShopify => 'షాపిఫైలో ఆర్డర్ ట్రాక్ చేయండి';

  @override
  String get orderInfo => 'ఆర్డర్ సమాచారం';

  @override
  String get placedOn => 'నాడు ఉంచబడింది';

  @override
  String get payment => 'చెల్లింపు';

  @override
  String get yourOrderItems => 'మీ ఆర్డర్ వస్తువులు';

  @override
  String get billSummary => 'బిల్లు సారాంశం';

  @override
  String get itemTotal => 'వస్తువు మొత్తం';

  @override
  String get deliveryCharge => 'డెలివరీ ఛార్జీ';

  @override
  String get handlingFee => 'హ్యాండ్లింగ్ ఫీజు';

  @override
  String get grandTotal => 'మొత్తం';

  @override
  String get needHelp => 'ఈ ఆర్డర్‌తో సహాయం కావాలా?';

  @override
  String paidVia(Object method) {
    return '$method ద్వారా చెల్లించబడింది';
  }

  @override
  String get cancelOrder => 'ఆర్డర్ రద్దు చేయండి';

  @override
  String get cancellationReason => 'దయచేసి రద్దు చేయడానికి కారణాన్ని ఎంచుకోండి';

  @override
  String get goBack => 'వెనక్కి వెళ్ళండి';

  @override
  String get cancelSuccess => 'ఆర్డర్ విజయవంతంగా రద్దు చేయబడింది';

  @override
  String get cancelFail =>
      'ఆర్డర్ రద్దు చేయడం విఫలమైంది. దయచేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get reasonChangedMind => 'నా ఆలోచన మారింది';

  @override
  String get reasonMistake => 'పొరపాటున ఆర్డర్ చేసాను';

  @override
  String get reasonBetterPrice => 'వేరే చోట తక్కువ ధర దొరికింది';

  @override
  String get reasonLongTime => 'డెలివరీ సమయం చాలా ఎక్కువగా ఉంది';

  @override
  String get reasonCoupon => 'కూపన్ అప్లై చేయడం మర్చిపోయాను';

  @override
  String get reasonOther => 'ఇతర';

  @override
  String get statusDeliveredMsg => 'మీ ఇంటి వద్ద విజయవంతంగా డెలివరీ చేయబడింది.';

  @override
  String get statusShippedMsg => 'వ్యాపారి ఆర్డర్‌ను కొరియర్‌కు అందజేశారు.';

  @override
  String get statusProcessingMsg =>
      'ఆర్డర్ ప్యాక్ చేయబడుతోంది మరియు పికప్ కోసం సిద్ధం చేయబడుతోంది.';

  @override
  String get statusCancelledMsg =>
      'మీ ఆర్డర్ రద్దు చేయబడింది. రీఫండ్ ప్రాసెస్ చేయబడుతుంది.';

  @override
  String get statusDefaultMsg =>
      'గొప్పది! మీకు సేవ చేయడానికి ఎదురుచూస్తున్నాము.';

  @override
  String get shopByCategory => 'వర్గం వారీగా షాపింగ్ చేయండి';

  @override
  String categoryCount(Object count) {
    return '$count వర్గాలు';
  }

  @override
  String get premiumSelection => 'ప్రీమియం ఎంపిక';

  @override
  String get appBrandName => 'కృషి భండార్';

  @override
  String get madeWithHeartForFarmers => 'రైతు కోసం ❤️ తో తయారు చేయబడింది';

  @override
  String get review1Name => 'రాహుల్ శర్మ';

  @override
  String get review2Name => 'అమిత్ పటేల్';

  @override
  String get you => 'మీరు';

  @override
  String get appTagline => 'ప్రతి రైతు గుర్తింపు!';

  @override
  String get updateRequired => 'అప్‌డేట్ అవసరం';

  @override
  String get updateAvailable => 'అప్‌డేట్ అందుబాటులో ఉంది';

  @override
  String get forceUpdateMsg =>
      'ఒక ముఖ్యమైన అప్‌డేట్ అందుబాటులో ఉంది. దయచేసి కొనసాగించడానికి యాప్‌ను అప్‌డేట్ చేయండి.';

  @override
  String get optionalUpdateMsg =>
      'కొత్త ఫీచర్లు మరియు మెరుగుదలలతో యాప్ కొత్త వెర్షన్ అందుబాటులో ఉంది.';

  @override
  String get later => 'తర్వాత';

  @override
  String get updateNow => 'ఇప్పుడే అప్‌డేట్ చేయండి';

  @override
  String get welcomeTo => 'ప్రారంభిద్దాం';

  @override
  String get loginPrompt =>
      'కొనసాగించడానికి మీ మొబైల్ నంబర్‌తో సైన్ ఇన్ చేయండి';

  @override
  String get mobileNumber => 'మొబైల్ నంబర్';

  @override
  String get enterMobileValid => 'దయచేసి మీ మొబైల్ నంబర్‌ను నమోదు చేయండి';

  @override
  String get enterMobile10 => 'మొబైల్ నంబర్ 10 అంకెలు ఉండాలి';

  @override
  String tryAgainIn(Object seconds) {
    return '$seconds సెకన్లలో మళ్ళీ ప్రయత్నించండి';
  }

  @override
  String get sendOtp => 'OTP పంపండి';

  @override
  String get verificationSentMsg =>
      'మేము మీ నంబర్‌కు వెరిఫికేషన్ కోడ్‌ని పంపుతాము';

  @override
  String get agreeTermsMsg =>
      'కొనసాగించడం ద్వారా, మీరు మా నిబంధనలకు అంగీకరిస్తున్నారు';

  @override
  String get and => ' మరియు ';

  @override
  String get verifyPhone => 'మీ ఫోన్ నంబర్‌ను\nధృవీకరించండి';

  @override
  String get enterOtpPrompt => 'పంపిన 6-అంకెల కోడ్‌ని నమోదు చేయండి ';

  @override
  String get verifyOtp => 'OTP ధృవీకరించండి';

  @override
  String get resendOtpIn => 'లో మళ్ళీ OTP పంపండి ';

  @override
  String get resendOtp => 'మళ్ళీ OTP పంపండి';

  @override
  String get otpSentAgain => 'OTP మళ్ళీ పంపబడింది!';

  @override
  String get farmingEssentials => 'వ్యవసాయ అవసరాలు';

  @override
  String get slideToDelete =>
      'వస్తువులను తీసివేయడానికి ఎడమ వైపుకు స్లయిడ్ చేయండి';

  @override
  String get checkout => 'చెక్అవుట్';

  @override
  String get cart => 'కార్ట్';

  @override
  String get address => 'చిరునామా';

  @override
  String get basketEmpty => 'బాస్కెట్ ఖాళీగా ఉంది';

  @override
  String get basketEmptyMsg =>
      'మీ బాస్కెట్ మా పొలాల నుండి తాజా,\nనాణ్యమైన వ్యవసాయ అవసరాల కోసం వేచి ఉంది.';

  @override
  String get startShopping => 'షాపింగ్ ప్రారంభించండి';

  @override
  String get pureOrganicQuality => 'ప్రీమియం నాణ్యత ఎంపిక';

  @override
  String get haveCoupon => 'కూపన్ కోడ్ ఉందా?';

  @override
  String get couponApplied => 'కూపన్ అప్లై చేయబడింది';

  @override
  String get saveMoreMsg => 'మీ ఆర్డర్‌పై మరింత ఆదా చేయండి';

  @override
  String couponAppliedMsg(Object code) {
    return '$code విజయవంతంగా అప్లై చేయబడింది';
  }

  @override
  String youSaved(Object amount) {
    return 'మీరు ఈ ఆర్డర్‌పై $amount ఆదా చేశారు';
  }

  @override
  String get free => 'ఉచితం';

  @override
  String get deliveryAddress => 'డెలివరీ చిరునామా';

  @override
  String deliveringTo(Object name) {
    return '$name కు డెలివరీ చేయబడుతోంది';
  }

  @override
  String orderSuccessMsg(Object title) {
    return '$title తో షాపింగ్ చేసినందుకు ధన్యవాదాలు. మీ ఆర్డర్ ఖరారు చేయబడింది.';
  }

  @override
  String get orderSuccessTitle => 'ఆర్డర్ విజయం';

  @override
  String get kisanSewaKendra => 'Krishi Bhandar';

  @override
  String get amountPending => 'పెండింగ్‌లో ఉన్న మొత్తం';

  @override
  String get paymentMethod => 'చెల్లింపు పద్ధతి';

  @override
  String get cod => 'క్యాష్ ఆన్ డెలివరీ (COD)';

  @override
  String get onlinePayment => 'ఆన్‌లైన్ చెల్లింపు';

  @override
  String get confirmationEmailMsg => 'మీరు త్వరలో నిర్ధారణ ఇమెయిల్ అందుకుంటారు';

  @override
  String get continueShopping => 'షాపింగ్ కొనసాగించండి';

  @override
  String get couponDiscount => 'కూపన్ తగ్గింపు';

  @override
  String get deliveryFee => 'డెలివరీ ఫీజు';

  @override
  String get change => 'మార్చు';

  @override
  String get orderNumber => 'ఆర్డర్ సంఖ్య';

  @override
  String get amountPaid => 'చెల్లించిన మొత్తం';

  @override
  String get paymentId => 'చెల్లింపు ID';

  @override
  String get noProductsFound => 'ఈ వర్గంలో ఉత్పత్తులేవీ కనుగొనబడలేదు';

  @override
  String get sortBy => 'దీని ప్రకారం క్రమబద్ధీకరించు';

  @override
  String get add => 'జోడించు';

  @override
  String get options => 'ఎంపికలు';

  @override
  String get selectOption => 'ఎంపికను ఎంచుకోండి';

  @override
  String get productUnavailable => 'ఉత్పత్తి వివరాలు ప్రస్తుతం అందుబాటులో లేవు';

  @override
  String get brand => 'బ్రాండ్';

  @override
  String get fastDelivery => 'వేగవంతమైన డెలివరీ';

  @override
  String get inclusiveTaxes => 'అన్ని పన్నులతో కలిపి';

  @override
  String get trust1Line1 => '100%';

  @override
  String get trust1Line2 => 'అసలైన ఉత్పత్తులు';

  @override
  String get trust2Line1 => 'సురక్షిత';

  @override
  String get trust2Line2 => 'చెల్లింపులు';

  @override
  String get trust3Line1 => 'ఉత్తమ ఫలితాలు';

  @override
  String get trust3Line2 => 'గ్యారెంటీ';

  @override
  String get selectVariant => 'వేరియంట్‌ను ఎంచుకోండి';

  @override
  String get overview => 'అవలోకనం';

  @override
  String get similarProducts => 'పోలిన ఉత్పత్తులు';

  @override
  String get viewAll => 'అన్నీ చూడండి';

  @override
  String get addedToCart => 'ఉత్పత్తి కార్ట్‌కు జోడించబడింది!';

  @override
  String get easy => 'సులభం';

  @override
  String get fast => 'వేగంగా';

  @override
  String get addToCart => 'కార్ట్‌కు జోడించు';

  @override
  String get buyNow => 'ఇప్పుడే కొనండి';

  @override
  String get productName => 'ఉత్పత్తి పేరు';

  @override
  String get category => 'వర్గం';

  @override
  String get technicalContent => 'సాంకేతిక కంటెంట్';

  @override
  String get noDescription => 'వివరణ అందుబాటులో లేదు.';

  @override
  String get aboutProduct => 'ఉత్పత్తి గురించి';

  @override
  String get viewMore => 'మరిన్ని చూడండి';

  @override
  String get viewLess => 'తక్కువ చూడండి';

  @override
  String get howToUse => 'ఎలా ఉపయోగించాలి';

  @override
  String get dosage => 'మోతాదు';

  @override
  String get applyTime => 'ఉపయోగించే సమయం';

  @override
  String get method => 'పద్ధతి';

  @override
  String get writeReview => 'సమీక్ష రాయండి';

  @override
  String get shareExperience => 'ఈ ఉత్పత్తితో మీ అనుభవాన్ని పంచుకోండి';

  @override
  String get describeExperience => 'మీ అనుభవాన్ని వివరించండి...';

  @override
  String get submitReview => 'సమీక్షను సమర్పించండి';

  @override
  String get customerReviews => 'కస్టమర్ సమీక్షలు';

  @override
  String get dosageDesc => 'లీటర్ నీటికి 2-3 మి.లీ కలపండి.';

  @override
  String get applyTimeDesc => 'ఉదయం పూట లేదా సాయంత్రం పూట వాడటం ఉత్తమం.';

  @override
  String get methodDesc => 'గరిష్ట ప్రభావం కోసం ఆకులపై స్ప్రే చేయండి.';

  @override
  String get review1Comment =>
      'చాలా ప్రభావవంతమైన ఉత్పత్తి. కేవలం 1 వారంలో ఫలితాలను చూశాను. బాగా సిఫార్సు చేస్తున్నాను!';

  @override
  String get review2Comment =>
      'మంచి నాణ్యత మరియు అసలైన ఉత్పత్తి. ప్యాకేజింగ్ కూడా చాలా బాగుంది.';

  @override
  String daysAgo(Object count) {
    return '$count రోజుల క్రితం';
  }

  @override
  String off(Object percentage) {
    return '$percentage% తగ్గింపు';
  }

  @override
  String get pgr => 'PGRలు';

  @override
  String get npkFertilizer => 'NPK ఎరువులు';

  @override
  String get bioPesticide => 'బయో-క్రిమిసంహారిణులు';

  @override
  String get bioFungicide => 'బయో-శిలీంధ్ర సంహారిణి';

  @override
  String get bioFertilizer => 'బయో-ఎరువులు';

  @override
  String get selectAddressToProceed =>
      'కొనసాగడానికి డెలివరీ చిరునామాను ఎంచుకోండి';

  @override
  String get addDeliveryAddress => 'డెలివరీ చిరునామాను జోడించండి';

  @override
  String get proceedToPlaceOrder => 'ఆర్డర్ చేయడానికి కొనసాగండి';

  @override
  String get paymentOptions => 'చెల్లింపు ఎంపికలు';

  @override
  String get choosePreferredMethod => 'మీకు నచ్చిన పద్ధతిని ఎంచుకోండి';

  @override
  String get couponActiveOnlineDisabled =>
      'కూపన్ యాక్టివ్‌లో ఉంది: ఆన్‌లైన్ తగ్గింపు నిలిపివేయబడింది.';

  @override
  String get payMethodSubtitle => 'UPI, కార్డ్‌లు, వాలెట్లు';

  @override
  String get codSubtitle => 'మీ ఇంటి వద్దే చెల్లించండి';

  @override
  String get secureTransactions => '100% సురక్షిత లావాదేవీలు';

  @override
  String get trustBadges => 'ప్రామాణిక • ధృవీకరించబడిన • నమ్మదగిన';

  @override
  String get applyCoupon => 'కూపన్ అప్లై చేయండి';

  @override
  String get enterCouponCode => 'కూపన్ కోడ్‌ను నమోదు చేయండి';

  @override
  String get apply => 'అప్లై చేయండి';

  @override
  String get invalidCoupon => 'చెల్లని లేదా గడువు ముగిసిన కూపన్ కోడ్.';

  @override
  String get newDeliveryAddress => 'కొత్త డెలివరీ చిరునామా';

  @override
  String get firstName => 'మొదటి పేరు';

  @override
  String get lastName => 'చివరి పేరు';

  @override
  String get placeholderFirstName => 'మొదటి పేరు';

  @override
  String get placeholderLastName => 'చివరి పేరు';

  @override
  String get enterPhoneNumber => 'ఫోన్ నంబర్ నమోదు చేయండి';

  @override
  String get errPhoneRequired => 'దయచేసి ఫోన్ నంబర్ నమోదు చేయండి';

  @override
  String get errPhoneValid => 'చెల్లుబాటు అయ్యే 10-అంకెల సంఖ్యను నమోదు చేయండి';

  @override
  String get locating => 'గుర్తిస్తోంది...';

  @override
  String get useCurrentLocation => 'ప్రస్తుత స్థానాన్ని ఉపయోగించండి';

  @override
  String get pincode => 'పిన్‌కోడ్';

  @override
  String get addressLine1 => 'చిరునామా వరుస 1';

  @override
  String get addressLine1Hint => 'ఇంటి నంబర్, వీధి, ప్రాంతం';

  @override
  String get addressLine2 => 'చిరునామా వరుస 2 (ఐచ్ఛికం)';

  @override
  String get addressLine2Hint => 'ల్యాండ్‌మార్క్, కాలనీ, మొదలైనవి.';

  @override
  String get cityDistrict => 'నగరం / జిల్లా';

  @override
  String get state => 'రాష్ట్రం';

  @override
  String get addNew => 'కొత్తది జోడించు';

  @override
  String get selectAddress => 'చిరునామాను ఎంచుకోండి';

  @override
  String get saveAndConfirm => 'సేవ్ చేసి ధృవీకరించండి';

  @override
  String get confirmAddress => 'చిరునామాను నిర్ధారించండి';

  @override
  String get locationDisabled => 'స్థాన సేవలు నిలిపివేయబడ్డాయి.';

  @override
  String get locationDenied => 'స్థాన అనుమతులు నిరాకరించబడ్డాయి.';

  @override
  String get locationPermanentlyDenied =>
      'స్థాన అనుమతులు శాశ్వతంగా నిరాకరించబడ్డాయి.';

  @override
  String get locationFailed => 'స్థానాన్ని పొందడంలో విఫలమైంది';

  @override
  String get fieldRequired => 'ఈ ఫీల్డ్ అవసరం';

  @override
  String get placeholderCity => 'నగరం';

  @override
  String get placeholderState => 'రాష్ట్రం';

  @override
  String get placeholderPincode => 'పిన్‌కోడ్';

  @override
  String get clearCart => 'అన్నీ తీసివేయి';

  @override
  String get clearCartConfirm => 'కార్ట్‌ను ఖాళీ చేయాలా?';

  @override
  String get clearCartConfirmMsg =>
      'మీరు ఖచ్చితంగా మీ కార్ట్ నుండి అన్ని వస్తువులను తీసివేయాలనుకుంటున్నారా?';

  @override
  String get cancel => 'రద్దు చేయి';

  @override
  String get addFollowingToGetFree => 'Add following to get free:';
}
