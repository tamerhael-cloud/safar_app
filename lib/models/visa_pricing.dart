class VisaType {
  final String titleAr;
  final String titleEn;
  double price; // Made mutable
  final String descriptionAr;
  final String descriptionEn;
  String termsAr;
  String termsEn;

  VisaType({
    required this.titleAr,
    required this.titleEn,
    required this.price,
    this.descriptionAr = '',
    this.descriptionEn = '',
    this.termsAr = '',
    this.termsEn = '',
  });
}

class CountryVisaData {
  final String nameAr;
  final String nameEn;
  final List<VisaType> types;

  CountryVisaData({
    required this.nameAr,
    required this.nameEn,
    required this.types,
  });
}

final List<CountryVisaData> visaPricingData = [
  CountryVisaData(
    nameAr: 'الأردن',
    nameEn: 'Jordan',
    types: [
      VisaType(titleAr: 'عادية', titleEn: 'Regular', price: 65, descriptionAr: 'مدة معالجة عادية'),
      VisaType(titleAr: 'مستعجلة', titleEn: 'Urgent', price: 100, descriptionAr: 'معالجة سريعة'),
      VisaType(titleAr: 'طارئة', titleEn: 'Emergency', price: 150, descriptionAr: 'معالجة فورية (يوم عمل)'),
    ],
  ),
  CountryVisaData(
    nameAr: 'مصر',
    nameEn: 'Egypt',
    types: [
      VisaType(titleAr: 'أمن وطني', titleEn: 'National Security', price: 200, descriptionAr: 'خلال أسبوع عمل'),
      VisaType(titleAr: 'مخابرات', titleEn: 'Intelligence', price: 150, descriptionAr: 'خلال أسبوع عمل'),
      VisaType(titleAr: 'مستعجلة', titleEn: 'Urgent', price: 250),
    ],
  ),
  CountryVisaData(
    nameAr: 'سلطنة عمان',
    nameEn: 'Oman',
    types: [
      VisaType(titleAr: 'لمدة 5 أيام', titleEn: '5 Days', price: 100),
      VisaType(titleAr: 'لمدة 21 يوم', titleEn: '21 Days', price: 200),
      VisaType(titleAr: 'متعددة الدخول', titleEn: 'Multiple Entry', price: 350),
    ],
  ),
  CountryVisaData(
    nameAr: 'الإمارات',
    nameEn: 'UAE',
    types: [
      VisaType(titleAr: 'سياحة لمدة شهر', titleEn: '1 Month Tourism', price: 200),
    ],
  ),
  CountryVisaData(
    nameAr: 'تايلاند',
    nameEn: 'Thailand',
    types: [
      VisaType(titleAr: 'عادية', titleEn: 'Regular', price: 200),
      VisaType(titleAr: 'مستعجلة', titleEn: 'Urgent', price: 300),
    ],
  ),
  CountryVisaData(
    nameAr: 'تركيا',
    nameEn: 'Turkey',
    types: [
      VisaType(titleAr: 'حامل شنجن/مقيم أمريكا', titleEn: 'Schengen/US Resident', price: 150, descriptionAr: 'إلكترونية مشروطة'),
    ],
  ),
   CountryVisaData(
    nameAr: 'السعودية',
    nameEn: 'Saudi Arabia',
    types: [
      VisaType(titleAr: 'زيارة شخصية', titleEn: 'Personal Visit', price: 300),
      VisaType(titleAr: 'عمرة', titleEn: 'Umrah', price: 250),
    ],
  ),
  CountryVisaData(
    nameAr: 'إندونيسيا',
    nameEn: 'Indonesia',
    types: [
      VisaType(titleAr: 'عادية', titleEn: 'Regular', price: 180),
    ],
  ),
  CountryVisaData(
    nameAr: 'سنغافورة',
    nameEn: 'Singapore',
    types: [
      VisaType(titleAr: 'إلكترونية', titleEn: 'E-Visa', price: 150),
    ],
  ),
];
