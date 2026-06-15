import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';
import '../screens/add_transaction_screen.dart';
import '../theme/app_theme.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppTheme.accentGreen : AppTheme.accentRed;
    final catColor = _getCategoryColor(transaction.category);

    return Dismissible(
      key: Key('txn_${transaction.key}'),
      // Both directions enabled — each has its own background
      background: _buildEditBackground(isDark),         // left-to-right = edit
      secondaryBackground: _buildDeleteBackground(),    // right-to-left = delete
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Edit — navigate to edit screen, never actually dismiss
          HapticFeedback.lightImpact();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionScreen(existing: transaction),
            ),
          );
          return false; // don't remove card
        } else {
          // Delete — show confirm dialog
          return await _confirmDelete(context, isDark);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          transaction.delete();
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Transaction deleted'),
            backgroundColor: AppTheme.accentRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_getCategoryIcon(transaction.category),
                  color: catColor, size: 20),
            ),
            const SizedBox(width: 12),
            // Title + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          transaction.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: catColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(transaction.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black.withOpacity(0.38),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'} Rs.${_formatAmount(transaction.amount)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isIncome ? 'Credit' : 'Debit',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── swipe LEFT-TO-RIGHT background (edit) ──────────────────────────────────
  Widget _buildEditBackground(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accentCyan.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_rounded, color: AppTheme.accentCyan, size: 20),
          const SizedBox(width: 6),
          Text(
            'Edit',
            style: TextStyle(
              color: AppTheme.accentCyan,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── swipe RIGHT-TO-LEFT background (delete) ─────────────────────────────────
  Widget _buildDeleteBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accentRed.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Delete',
            style: TextStyle(
              color: AppTheme.accentRed,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.delete_outline_rounded,
              color: AppTheme.accentRed, size: 20),
        ],
      ),
    );
  }

  // ── confirm delete dialog ───────────────────────────────────────────────────
  Future<bool> _confirmDelete(BuildContext context, bool isDark) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor:
                isDark ? AppTheme.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Delete Transaction?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            content: Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black.withOpacity(0.54),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black.withOpacity(0.45))),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Delete',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ── helpers ────────────────────────────────────────────────────────────────
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year)
      return 'Today';
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000)
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food': return const Color(0xFFFF6B6B);
      case 'travel': return const Color(0xFF4ECDC4);
      case 'shopping': return const Color(0xFF45B7D1);
      case 'billing': return const Color(0xFFFFBE0B);
      case 'entertainment': return const Color(0xFFBB8FCE);
      case 'salary': return const Color(0xFF00E5A0);
      case 'bonus': return const Color(0xFF00D4FF);
      default: return const Color(0xFF8B5CF6);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant_rounded;
      case 'travel': return Icons.flight_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'billing': return Icons.receipt_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'salary': return Icons.payments_rounded;
      case 'bonus': return Icons.card_giftcard_rounded;
      default: return Icons.category_rounded;
    }
  }
}
