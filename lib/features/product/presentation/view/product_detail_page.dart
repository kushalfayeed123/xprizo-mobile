// ignore_for_file: unawaited_futures

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xprizo_mobile/core/widgets/payment_status_dialog.dart';
import 'package:xprizo_mobile/features/product/data/models/product_model.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_bloc.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_event.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({required this.product, super.key});
  final ProductModel product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<dynamic>? _sub;
  String? _paymentStatus;
  bool _isLoading = false;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _listenForPaymentRedirect();
  }

  void _listenForPaymentRedirect() {
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        if (uri.scheme == 'myapp') {
          if (mounted) {
            setState(() {
              _paymentStatus = 'Payment successful!';
            });
            context.read<ProductBloc>().add(
                  SetRedirectLink(
                    widget.product.id,
                    message: 'Payment successful!',
                    messageType: MessageType.success,
                  ),
                );
            Navigator.pop(context); // Close WebView
          }
        }
      },
      onError: (dynamic error) {
        debugPrint('Error listening to deep links: $error');
        if (mounted) {
          context.read<ProductBloc>().add(
                SetRedirectLink(
                  widget.product.id,
                  message: 'Error processing payment redirect',
                  messageType: MessageType.error,
                ),
              );
        }
      },
    );
  }

  void _handlePaymentCallback(String status, String reference) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentStatusDialog(
        status: status,
        reference: reference,
        onOkPressed: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Go back to list
        },
      ),
    );
  }

  Future<void> _launchPaymentUrl(ProductModel product) async {
    if (!mounted) return;

    try {
      // Set up the redirect URL first
      context.read<ProductBloc>().add(
            SetRedirectLink(
              product.id,
              message: 'Setting up payment...',
              messageType: MessageType.info,
            ),
          );

      // Launch WebView for payment
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              WebViewWidget(
                controller: WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..setNavigationDelegate(
                    NavigationDelegate(
                      onPageFinished: (String url) {
                        if (url.contains('status=') &&
                            url.contains('reference=')) {
                          final uri = Uri.parse(url);
                          final status = uri.queryParameters['status'] ?? '';
                          final reference =
                              uri.queryParameters['reference'] ?? '';
                          Navigator.of(context).pop(); // Close WebView
                          _handlePaymentCallback(status, reference);
                        }
                      },
                    ),
                  )
                  ..loadRequest(Uri.parse(product.paymentUrl ?? '')),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to launch payment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _webViewController?.clearCache();
    _webViewController?.clearLocalStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image banner
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/product-1.jpg',
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    product.description ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${product.currencyCode} ${product.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reference
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reference',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.reference ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed:
                          _isLoading ? null : () => _launchPaymentUrl(product),
                      icon: const Icon(Icons.payment),
                      label: Text(
                        _isLoading ? 'Processing...' : 'Proceed to Payment',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Show payment status if available
                  if (_paymentStatus != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Payment Status: $_paymentStatus',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
