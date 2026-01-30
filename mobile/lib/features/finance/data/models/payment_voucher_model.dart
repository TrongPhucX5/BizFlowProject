class PaymentVoucher {
  final int id;
  final String reason;
  final double amount;
  final String receiverName;
  final DateTime date;
  final String? evidenceImageUrl;
  final String type; // CASH, TRANSFER

  PaymentVoucher({
    required this.id,
    required this.reason,
    required this.amount,
    required this.receiverName,
    required this.date,
    this.evidenceImageUrl,
    this.type = 'CASH',
  });

  factory PaymentVoucher.fromJson(Map<String, dynamic> json) {
    return PaymentVoucher(
      id: json['id'] ?? 0,
      reason: json['reason'] ?? '',
      amount: double.tryParse((json['amount'] ?? 0).toString()) ?? 0.0,
      receiverName: json['receiverName'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      evidenceImageUrl: json['evidenceImageUrl'],
      type: json['type'] ?? 'CASH',
    );
  }
}
