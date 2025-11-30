import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/payment.dart';
import '../../viewmodels/payment_list_view_model.dart';

class PreacherPaymentHistoryScreen extends StatelessWidget {
  const PreacherPaymentHistoryScreen({super.key});

  static Widget withProvider({required String preacherId}) {
    return ChangeNotifierProvider(
      create: (_) => PaymentListViewModel(
        mode: PaymentListMode.preacherHistory,
        preacherId: preacherId,
      ),
      child: const PreacherPaymentHistoryScreen(),
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
          'Payment History',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(viewModel),
          _buildStatusFilterChips(viewModel),
          Expanded(child: _buildContent(context, viewModel)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(PaymentListViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: viewModel.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by activity...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChips(PaymentListViewModel viewModel) {
    final filters = ['All', 'Pending', 'Approved', 'Forwarded'];
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
      return const Center(child: Text('No payment history found.'));
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
    final statusColors = _getStatusColors(item.status);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.activityName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('dd MMM yyyy').format(item.activityDate),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
                color: statusColors['bgColor'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColors['textColor'],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getStatusColors(String status) {
    switch (status) {
      case 'Pending Payment':
        return {'bgColor': pendingBg, 'textColor': pendingText};
      case 'Approved by MUIP Officer':
      case 'Paid':
        return {'bgColor': approvedBg, 'textColor': approvedText};
      case 'Forwarded to Yayasan':
        return {'bgColor': forwardedBg, 'textColor': forwardedText};
      default:
        return {'bgColor': Colors.grey.shade200, 'textColor': Colors.grey.shade700};
    }
  }
}
