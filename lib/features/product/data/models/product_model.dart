class ProductModel {
  ProductModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.currencyCode,
    required this.contactId,
    required this.userName,
    required this.reference,
    required this.routingCode,
    required this.token,
    required this.isInactive,
    this.paymentUrl,
    this.symbol,
    this.redirectUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currencyCode: json['currencyCode'] as String? ?? 'EUR',
      paymentUrl: json['paymentUrl'] as String?,
      contactId: json['contactId'] as int,
      userName: json['userName'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      routingCode: json['routingCode'] as String? ?? '',
      token: json['token'] as String? ?? '',
      redirectUrl: json['redirectUrl'] as String?,
      isInactive: json['isInactive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'currencyCode': currencyCode,
        if (paymentUrl != null) 'paymentUrl': paymentUrl,
        'contactId': contactId,
        'userName': userName,
        if (symbol != null) 'symbol': symbol,
        'reference': reference,
        'routingCode': routingCode,
        'token': token,
        if (redirectUrl != null) 'redirectUrl': redirectUrl,
        'isInactive': isInactive,
      };

  final int id;
  final String? description;
  final int contactId;
  final String? userName;
  final double amount;
  final String? currencyCode;
  final String? symbol;
  final String? reference;
  final String? routingCode;
  final String? token;
  final String? paymentUrl;
  final String? redirectUrl;
  final bool isInactive;
}
