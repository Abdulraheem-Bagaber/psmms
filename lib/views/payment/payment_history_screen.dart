import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/payment.dart';
import '../../viewmodels/payment_list_view_model.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  static Widget withProvider() {
    return ChangeNotifierProvider(
      create: (_) => PaymentListViewModel(mode: PaymentListMode.adminHistory),
      child: const PaymentHistoryScreen(),
    );
  }

  static const Color bgScaffold = Color(0xFFF2F2F2);
  static const Color chipSelectedColor = Color(0xFF2563EB);
  static const Color chipUnselectedColor = Color(0xFFE5E7EB);
  static const Color pendingBg = Color(0xFFFFF4CC);
  static const Color pendingText = Color(0xFF92400E);
  static const Color approvedBg = Color(0xFFDCFCE7);
  static const Color approvedText = Color(0xFF166534);
  static const Color forwardedBg = Color(0xFFE0F2FE);
  static const Color forwardedText = Color(0xFF1D4ED8);
  static const Color rejectedBg = Color(0xFFFEE2E2);
  static const Color rejectedText = Color(0xFFB91C1C);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PaymentListViewModel>();

    return Scaffold(
      backgroundColor: bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Payment Approvals',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilterChips(viewModel),
          Expanded(child: _buildContent(context, viewModel)),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChips(PaymentListViewModel viewModel) {
    final filters = ['All', 'Pending', 'Approved', 'Forwarded', 'Rejected'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: filters.map((filter) {
          final isSelected = viewModel.statusFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => viewModel.onStatusFilterChanged(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? chipSelectedColor : chipUnselectedColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaymentListViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }

    if (viewModel.payments.isEmpty) {
      return const Center(child: Text('No payments found for this filter.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: viewModel.payments.length,
      itemBuilder: (context, index) {
        return _buildPaymentCard(viewModel.payments[index]);
      },
    );
  }

  Widget _buildPaymentCard(Payment item) {
    final statusInfo = _getStatusInfo(item.status);
    final initials = _getInitials(item.preacherName);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.preacherName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.activityName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMM yyyy').format(item.activityDate),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'RM ${item.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusInfo['bgColor'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusInfo['textColor'],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'Pending Payment':
        return {
          'label': 'Pending',
          'bgColor': pendingBg,
          'textColor': pendingText,
        };
      case 'Approved by MUIP Officer':
        return {
          'label': 'Approved',
          'bgColor': approvedBg,
          'textColor': approvedText,
        };
      case 'Forwarded to Yayasan':
        return {
          'label': 'Forwarded',
          'bgColor': forwardedBg,
          'textColor': forwardedText,
        };
      case 'Rejected':
        return {
          'label': 'Rejected',
          'bgColor': rejectedBg,
          'textColor': rejectedText,
        };
      default:
        return {
          'label': 'Unknown',
          'bgColor': Colors.grey.shade200,
          'textColor': Colors.grey.shade700,
        };
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1))
        .toUpperCase();
  }
}
