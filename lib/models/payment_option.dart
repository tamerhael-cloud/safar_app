class PaymentOption {
  String id;
  String titleAr;
  String titleEn;
  String detailsAr;
  String detailsEn;
  String iconType; // e.g., 'credit_card', 'wallet', 'bank'

  PaymentOption({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.detailsAr,
    required this.detailsEn,
    required this.iconType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'detailsAr': detailsAr,
      'detailsEn': detailsEn,
      'iconType': iconType,
    };
  }

  factory PaymentOption.fromMap(Map<String, dynamic> map) {
    return PaymentOption(
      id: map['id'],
      titleAr: map['titleAr'],
      titleEn: map['titleEn'],
      detailsAr: map['detailsAr'] ?? '',
      detailsEn: map['detailsEn'] ?? '',
      iconType: map['iconType'] ?? 'bank',
    );
  }
}
