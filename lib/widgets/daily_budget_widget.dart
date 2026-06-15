import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DailyBudgetWidget extends StatelessWidget {
  final double balance;
  final double totalExpense;

  const DailyBudgetWidget({
    super.key,
    required this.balance,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day + 1; // include today
    final daysPassed = now.day - 1;

    final double dailyBudget =
        (daysRemaining > 0 && balance > 0) ? balance / daysRemaining : 0;
    final double avgDailySpend =
        daysPassed > 0 ? totalExpense / daysPassed : 0;

    final BudgetStatus status = _getStatus(dailyBudget, avgDailySpend);
    final primaryColor =
        isDark ? AppTheme.accentCyan : AppTheme.lightPrimary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status.color.withOpacity(isDark ? 0.25 : 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.07),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: status.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(status.icon, color: status.color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Budget Advisor',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          )),
                      Text(
                        '$daysRemaining day${daysRemaining == 1 ? '' : 's'} left in ${_monthName(now.month)}',
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isDark ? Colors.white38 : Colors.black.withOpacity(0.38),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: status.color,
                      )),
                ),
              ],
            ),
          ),

          // ── Big daily amount ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOU CAN SPEND',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color:
                        isDark ? Colors.white.withOpacity(0.30) : Colors.black.withOpacity(0.30),
                  ),
                ),
                const SizedBox(height: 4),
                dailyBudget <= 0
                    ? Text(
                        'Rs. 0',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentRed,
                          letterSpacing: -1.5,
                        ),
                      )
                    : RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: 'Rs. ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.black.withOpacity(0.38),
                            ),
                          ),
                          TextSpan(
                            text: _formatAmount(dailyBudget),
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: status.color,
                              letterSpacing: -2,
                            ),
                          ),
                        ]),
                      ),
                const SizedBox(height: 2),
                Text(
                  'per day to last the month',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDark ? Colors.white38 : Colors.black.withOpacity(0.38),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Month progress bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Month progress',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white38
                              : Colors.black.withOpacity(0.38),
                        )),
                    Text(
                      'Day ${now.day} of $daysInMonth',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white54
                            : Colors.black.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: now.day / daysInMonth,
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.07)
                        : Colors.black.withOpacity(0.06),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(primaryColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Stats row ───────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildStatCell(
                  'Avg. Daily Spend',
                  daysPassed == 0
                      ? 'N/A'
                      : 'Rs. ${_formatAmount(avgDailySpend)}',
                  isDark,
                ),
                _buildVDivider(isDark),
                _buildStatCell(
                  'Balance Left',
                  'Rs. ${_formatAmount(balance)}',
                  isDark,
                ),
                _buildVDivider(isDark),
                _buildStatCell(
                  'Days to go',
                  '$daysRemaining day${daysRemaining == 1 ? '' : 's'}',
                  isDark,
                ),
              ],
            ),
          ),

          // ── Warning: spending more than budget ─────────────────────────────
          if (dailyBudget > 0 &&
              avgDailySpend > 0 &&
              dailyBudget < avgDailySpend)
            _buildAlert(
              Icons.warning_amber_rounded,
              AppTheme.accentAmber,
              'You\'re spending Rs.${_formatAmount(avgDailySpend - dailyBudget)} '
              'more per day than your budget allows.',
              isDark,
            ),

          // ── Alert: balance is negative ─────────────────────────────────────
          if (balance <= 0)
            _buildAlert(
              Icons.error_outline_rounded,
              AppTheme.accentRed,
              'Your balance is negative. Review your expenses immediately.',
              isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildAlert(
      IconData icon, Color color, String message, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCell(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white38 : Colors.black.withOpacity(0.38),
              ),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildVDivider(bool isDark) => Container(
        width: 1,
        height: 30,
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.08),
      );

  BudgetStatus _getStatus(double daily, double avg) {
    if (daily <= 0) {
      return BudgetStatus(
          label: 'Over Budget',
          icon: Icons.sentiment_very_dissatisfied_rounded,
          color: AppTheme.accentRed);
    }
    if (avg <= 0) {
      // No spending data yet — neutral
      return BudgetStatus(
          label: 'No Data Yet',
          icon: Icons.info_outline_rounded,
          color: AppTheme.accentCyan);
    }
    if (daily < avg * 0.5) {
      return BudgetStatus(
          label: 'Tight',
          icon: Icons.sentiment_dissatisfied_rounded,
          color: AppTheme.accentRed);
    }
    if (daily < avg) {
      return BudgetStatus(
          label: 'Be Careful',
          icon: Icons.sentiment_neutral_rounded,
          color: AppTheme.accentAmber);
    }
    if (daily < avg * 1.5) {
      return BudgetStatus(
          label: 'On Track',
          icon: Icons.sentiment_satisfied_rounded,
          color: AppTheme.accentCyan);
    }
    return BudgetStatus(
        label: 'Comfortable',
        icon: Icons.sentiment_very_satisfied_rounded,
        color: AppTheme.accentGreen);
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000)
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000)
      return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class BudgetStatus {
  final String label;
  final IconData icon;
  final Color color;
  const BudgetStatus(
      {required this.label, required this.icon, required this.color});
}
