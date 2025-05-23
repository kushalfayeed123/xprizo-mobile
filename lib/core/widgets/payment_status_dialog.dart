import 'package:flutter/material.dart';

class PaymentStatusDialog extends StatelessWidget {
  const PaymentStatusDialog({
    required this.status,
    required this.reference,
    required this.onOkPressed,
    super.key,
  });

  final String status;
  final String reference;
  final VoidCallback onOkPressed;

  @override
  Widget build(BuildContext context) {
    final isSuccess = status.toLowerCase() == 'success';
    final isPending = status.toLowerCase() == 'pending';

    Color statusColor;
    IconData statusIcon;
    String title;
    String message;

    if (isSuccess) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      title = 'Payment Successful';
      message = 'Your payment has been processed successfully.';
    } else if (isPending) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      title = 'Payment Pending';
      message =
          'Your payment is being processed. Please wait for confirmation.';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      title = 'Payment Failed';
      message = 'There was an issue processing your payment.';
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            'Reference: $reference',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onOkPressed,
          child: const Text(
            'OK',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
