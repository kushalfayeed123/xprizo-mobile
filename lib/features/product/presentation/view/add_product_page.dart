// lib/features/product/presentation/pages/add_product_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:xprizo_mobile/features/product/data/models/add_product_request_model.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_bloc.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_event.dart';
import 'package:xprizo_mobile/features/product/presentation/bloc/product_state.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final addRequest = AddProductRequestModel(
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        currencyCode: 'EUR',
        reference: const Uuid().v4(),
      );
      context.read<ProductBloc>().add(AddProduct(addRequest));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state.message?.isNotEmpty ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: state.messageType == MessageType.error
                  ? Colors.red
                  : Colors.green,
            ),
          );

          // Only navigate back on success
          if (state.messageType == MessageType.success) {
            Navigator.pop(context);
          }
        }
      },
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final isLoading = state is ProductLoading;
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: const Text('Add Product'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: isLoading ? null : () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Product Name Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          hintText: 'Enter product name',
                          prefixIcon: Icon(Icons.shopping_bag),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 20),

                      // Amount Field
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          hintText: 'Enter amount in EUR',
                          prefixIcon: Icon(Icons.euro),
                          suffixText: 'EUR',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) =>
                            value == null || double.tryParse(value) == null
                                ? 'Enter valid amount'
                                : null,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _submit,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.add_circle_outline),
                        label: Text(
                          isLoading ? 'Adding...' : 'Add Product',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
