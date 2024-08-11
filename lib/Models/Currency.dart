class Currency {
  final String id;
  final String? arabicName;
  final String? englishName;

  Currency({
    required this.id,
    this.arabicName,
    this.englishName,
  });

  factory Currency.fromMap(Map<String, dynamic> json) {
    return Currency(
      id: json['rowId'],
      arabicName: json['extValue1'],
      englishName: json['extValue2'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'arabicName': arabicName,
      'englishName': englishName,
    };
  }

  @override
  String toString() {
    return 'Currency{id: $id, arabicName: $arabicName, englishName: $englishName}';
  }
}
