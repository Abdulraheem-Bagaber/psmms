import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/payment.dart';
import '../../../viewmodels/payment_form_view_model.dart';

class PaymentFormScreen extends StatelessWidget {
  const PaymentFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Payment? activityPayment = ModalRoute.of(context)?.settings.arguments as Payment?;
    return ChangeNotifierProvider(
      create: (_) => PaymentFormViewModel(initialActivity: activityPayment),
      child: const _PaymentFormContent(),
    );
  }
}

class _PaymentFormContent extends StatelessWidget {
  const _PaymentFormContent();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Payment Form',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SafeArea(
          child: Consumer<PaymentFormViewModel>(
            builder: (context, viewModel, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (viewModel.successMessage != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(viewModel.successMessage!),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  viewModel.clearSuccessMessage();
                }
              });
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActivityDetailsCard(viewModel),
                      const SizedBox(height: 16),
                      _buildPaymentInformationCard(viewModel),
                      const SizedBox(height: 24),
                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066FF),
                            disabledBackgroundColor: const Color(0xFF99BFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          onPressed: viewModel.isSubmitting
                              ? null
                              : () async {
                                  FocusScope.of(context).unfocus();
                                  await viewModel.submitForApproval();
                                },
                          child: viewModel.isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.send_rounded, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Submit for Approval',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActivityDetailsCard(PaymentFormViewModel viewModel) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(icon: Icons.event, title: 'Activity Details'),
          const SizedBox(height: 16),
          _buildDetailRow('Activity ID', viewModel.activityId),
          _buildDetailRow('Activity Name', viewModel.activityName),
          _buildDetailRow('Preacher Name', viewModel.preacherName),
        ],
      ),
    );
  }

  Widget _buildPaymentInformationCard(PaymentFormViewModel viewModel) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(icon: Icons.payments_rounded, title: 'Payment Information'),
          const SizedBox(height: 16),
          TextFormField(
            controller: viewModel.paymentAmountController,
            onChanged: viewModel.onPaymentAmountChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _buildInputDecoration('Payment Amount'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: viewModel.remarksController,
            onChanged: viewModel.onRemarksChanged,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            decoration: _buildInputDecoration(
              'Remarks',
              hint: 'Enter any relevant notes or comments',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE5EEFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF0066FF)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.grey.shade900,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0066FF)),
      ),
      alignLabelWithHint: hint != null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
