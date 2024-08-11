class Bank {
  final String id;
  final String? arabicName;
  final String? englishName;

  Bank({
    required this.id,
    this.arabicName,
    this.englishName,
  });

  factory Bank.fromMap(Map<String, dynamic> json) {
    return Bank(
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
    return 'Bank{id: $id, arabicName: $arabicName, englishName: $englishName}';
  }
}
