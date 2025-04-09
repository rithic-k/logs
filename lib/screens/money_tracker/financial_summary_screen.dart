import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'package:google_fonts/google_fonts.dart';

class FinancialSummaryScreen extends StatefulWidget {
  const FinancialSummaryScreen({super.key});

  @override
  State<FinancialSummaryScreen> createState() => _FinancialSummaryScreenState();
}

class _FinancialSummaryScreenState extends State<FinancialSummaryScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Financial Summary'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final income = provider.getTotalIncome();
          final expense = provider.getTotalExpense();
          final balance = income - expense;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSummarySection(
                  'Income',
                  income,
                  Icons.arrow_upward,
                  AppColors.success,
                ),
                _buildSummarySection(
                  'Expense',
                  expense,
                  Icons.arrow_downward,
                  AppColors.error,
                ),
                _buildSummarySection(
                  'Balance',
                  balance,
                  Icons.account_balance_wallet,
                  balance >= 0 ? AppColors.success : AppColors.error,
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Recent Transactions',
                    style: AppTextStyles.heading2,
                  ),
                ),
                _buildRecentTransactions(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  textStyle: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(amount),
            style: AppTextStyles.heading1.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(TransactionProvider provider) {
    final transactions = provider.transactions.take(5).toList();

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No transactions yet',
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transaction.description,
                    style: AppTextStyles.body1,
                  ),
                ),
                Text(
                  currencyFormat.format(transaction.amount),
                  style: AppTextStyles.body1.copyWith(
                    color: transaction.type == TransactionType.income
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                DateFormat('MMM d, y').format(transaction.date),
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        );
      },
    );
  }
}
