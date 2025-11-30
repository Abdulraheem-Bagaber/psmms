import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment.dart';
import '../../viewmodels/payment_list_view_model.dart';

const Color primaryBlue = Color(0xFF0066FF);
const Color scaffoldBackground = Color(0xFFF2F2F2);
const Color pendingBackground = Color(0xFFFFF4CC);
const Color paidBackground = Color(0xFFCCF5D3);
const Color pendingAccent = Color(0xFFB58100);
const Color paidAccent = Color(0xFF0F8A43);

class ActivityPaymentsScreen extends StatelessWidget {
  const ActivityPaymentsScreen({super.key});

  static Widget withProvider() {
    return ChangeNotifierProvider(
      create: (_) => PaymentListViewModel(mode: PaymentListMode.officerPending),
      child: const ActivityPaymentsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PaymentListViewModel>();
    return Scaffold(
      backgroundColor: scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildSearchBar(viewModel),
              const SizedBox(height: 16),
              Expanded(
                child: _buildContent(context, viewModel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const Expanded(
          child: Text(
            'Activity Payments',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildSearchBar(PaymentListViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        initialValue: viewModel.searchQuery,
        onChanged: viewModel.onSearchChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Search by Preacher or Activity ID...',
          icon: Icon(Icons.search_rounded),
        ),
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
      return const Center(child: Text('No pending payments found.'));
    }
    return ListView.builder(
      itemCount: viewModel.payments.length,
      itemBuilder: (context, index) => _buildPaymentCard(context, viewModel, viewModel.payments[index]),
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentListViewModel viewModel, Payment item) {
    final bool isPending = item.status == 'Pending Payment';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: ${item.activityId}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildStatusChip(item.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.preacherName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16),
              const SizedBox(width: 6),
              Text(
                _formatDate(item.activityDate),
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.activityName,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('View Details'),
              ),
              if (isPending) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/payment-form',
                      arguments: item,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Process Payment'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final bool isPending = status == 'Pending Payment';
    final Color background = isPending ? pendingBackground : paidBackground;
    final Color accent = isPending ? pendingAccent : paidAccent;
    final String label = isPending ? 'Pending Payment' : 'Paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const List<String> monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final String day = date.day.toString().padLeft(2, '0');
    final String month = monthNames[date.month - 1];
    final String year = date.year.toString();
    return '$day $month $year';
  }
}
