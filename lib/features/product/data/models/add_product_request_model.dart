// lib/features/product/data/models/add_product_request_model.dart

class AddProductRequestModel {
  AddProductRequestModel({
    required this.description,
    required this.amount,
    required this.currencyCode,
    required this.reference,
  });

  final String description;
  final double amount;
  final String currencyCode;
  final String reference;

  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
        'currencyCode': currencyCode,
        'reference': reference,
      };
}
