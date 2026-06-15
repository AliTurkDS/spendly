import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/hive_service.dart';
import '../widgets/chart_widget.dart';
import '../widgets/transaction_card.dart';
import '../widgets/daily_budget_widget.dart';
import '../theme/app_theme.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const DashboardScreen({super.key, required this.toggleTheme});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  late TabController _tabController;
  String _filterType = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ValueListenableBuilder(
        valueListenable: HiveService.getBox().listenable(),
        builder: (context, box, _) {
          final allTransactions = HiveService.getTransactions();
          final now = DateTime.now();
          final filtered = allTransactions
              .where((t) =>
                  t.date.month == now.month && t.date.year == now.year)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          double income = 0, expense = 0;
          for (var t in filtered) {
            if (t.isIncome) income += t.amount;
            else expense += t.amount;
          }
          final double balance = income - expense;

          final displayList = _filterType == 'All'
              ? filtered
              : _filterType == 'Income'
                  ? filtered.where((t) => t.isIncome).toList()
                  : filtered.where((t) => !t.isIncome).toList();

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, isDark, allTransactions),
              SliverToBoxAdapter(
                child: _buildBalanceCard(
                    context, balance, income, expense, isDark),
              ),
              SliverToBoxAdapter(
                child: _buildTabBar(context, isDark),
              ),

              // ── OVERVIEW TAB ──────────────────────────────────────────────
              if (_selectedTab == 0) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: DailyBudgetWidget(
                      balance: balance,
                      totalExpense: expense,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildQuickStats(context, filtered, isDark),
                ),
                SliverToBoxAdapter(
                  child: _buildRecentHeader(context, isDark),
                ),
                if (filtered.isEmpty)
                  SliverToBoxAdapter(
                      child: _buildEmptyState(context, isDark))
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final recent = filtered.take(2).toList();
                        if (i >= recent.length) return null;
                        return TransactionCard(transaction: recent[i]);
                      },
                      childCount: filtered.take(2).length,
                    ),
                  ),
              ],

              // ── HISTORY TAB ───────────────────────────────────────────────
              if (_selectedTab == 1) ...[
                SliverToBoxAdapter(
                    child: _buildFilterChips(context, isDark)),
                if (displayList.isEmpty)
                  SliverToBoxAdapter(
                      child: _buildEmptyState(context, isDark))
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) =>
                          TransactionCard(transaction: displayList[i]),
                      childCount: displayList.length,
                    ),
                  ),
              ],

              // ── ANALYTICS TAB ─────────────────────────────────────────────
              if (_selectedTab == 2) ...[
                SliverToBoxAdapter(
                  child: ChartWidget(transactions: filtered),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── App bar with Clear Records button in overflow menu ──────────────────────
  Widget _buildSliverAppBar(BuildContext context, bool isDark, List allTransactions) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_getGreeting(),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black.withOpacity(0.45),
                fontWeight: FontWeight.w400,
              )),
          Text('My Finances',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
        ],
      ),
      actions: [
        // Theme toggle
        IconButton(
          icon: Icon(
            isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
            color: isDark ? Colors.white70 : Colors.black.withOpacity(0.54),
          ),
          onPressed: widget.toggleTheme,
        ),
        // Overflow menu
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded,
              color: isDark ? Colors.white70 : Colors.black.withOpacity(0.54)),
          color: isDark ? AppTheme.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          onSelected: (val) {
            if (val == 'clear_month') {
              _confirmClearMonth(context, isDark);
            } else if (val == 'clear_all') {
              _confirmClearAll(context, isDark);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'clear_month',
              child: Row(children: [
                Icon(Icons.calendar_month_rounded,
                    size: 18,
                    color: AppTheme.accentAmber),
                const SizedBox(width: 10),
                Text('Clear This Month',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentAmber,
                    )),
              ]),
            ),
            PopupMenuItem(
              value: 'clear_all',
              child: Row(children: [
                Icon(Icons.delete_sweep_rounded,
                    size: 18, color: AppTheme.accentRed),
                const SizedBox(width: 10),
                Text('Clear All Records',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentRed,
                    )),
              ]),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Clear this month's records ───────────────────────────────────────────────
  void _confirmClearMonth(BuildContext context, bool isDark) {
    final now = DateTime.now();
    _showClearDialog(
      context: context,
      isDark: isDark,
      title: 'Clear This Month?',
      subtitle:
          'All transactions from ${_getMonthName()} ${now.year} will be permanently deleted.',
      icon: Icons.calendar_month_rounded,
      iconColor: AppTheme.accentAmber,
      confirmLabel: 'Clear Month',
      confirmColor: AppTheme.accentAmber,
      onConfirm: () {
        final box = HiveService.getBox();
        final toDelete = box.values
            .where((t) =>
                t.date.month == now.month && t.date.year == now.year)
            .toList();
        for (final t in toDelete) {
          t.delete();
        }
        HapticFeedback.mediumImpact();
        _showSuccess(
            context, '${toDelete.length} transactions cleared');
      },
    );
  }

  // ── Clear ALL records ────────────────────────────────────────────────────────
  void _confirmClearAll(BuildContext context, bool isDark) {
    _showClearDialog(
      context: context,
      isDark: isDark,
      title: 'Clear All Records?',
      subtitle:
          'Every transaction will be permanently deleted. This cannot be undone.',
      icon: Icons.delete_sweep_rounded,
      iconColor: AppTheme.accentRed,
      confirmLabel: 'Clear All',
      confirmColor: AppTheme.accentRed,
      onConfirm: () {
        HiveService.getBox().clear();
        HapticFeedback.mediumImpact();
        _showSuccess(context, 'All records cleared');
      },
    );
  }

  void _showClearDialog({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        title: Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            )),
        content: Text(subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black.withOpacity(0.54),
              fontSize: 13,
            )),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: isDark
                      ? Colors.white12
                      : const Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
            ),
            child: Text('Cancel',
                style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black.withOpacity(0.45),
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
            ),
            child: Text(confirmLabel,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded,
            color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(message),
      ]),
      backgroundColor: AppTheme.accentGreen,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Balance card ─────────────────────────────────────────────────────────────
  Widget _buildBalanceCard(BuildContext context, double balance,
      double income, double expense, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A2A4A), Color(0xFF0D1B2E)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
        border: Border.all(
          color:
              isDark ? Colors.white.withOpacity(0.08) : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.accentCyan.withOpacity(0.08)
                : AppTheme.lightPrimary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Balance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  )),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_getMonthName(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rs. ${_formatAmount(balance)}',
            style: TextStyle(
              color: balance >= 0 ? Colors.white : AppTheme.accentRed,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBalanceStat(
                    'Income', income, AppTheme.accentGreen,
                    Icons.arrow_downward_rounded),
              ),
              Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 16)),
              Expanded(
                child: _buildBalanceStat(
                    'Expense', expense, AppTheme.accentRed,
                    Icons.arrow_upward_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStat(
      String label, double amount, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                )),
            Text('Rs. ${_formatAmount(amount)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ],
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────────
  Widget _buildTabBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            _buildTabItem(
                context, 0, 'Overview', Icons.grid_view_rounded, isDark),
            _buildTabItem(
                context, 1, 'History', Icons.receipt_long_rounded, isDark),
            _buildTabItem(
                context, 2, 'Analytics', Icons.bar_chart_rounded, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, String label,
      IconData icon, bool isDark) {
    final isSelected = _selectedTab == index;
    final primaryColor =
        isDark ? AppTheme.accentCyan : AppTheme.lightPrimary;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
          _tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(isDark ? 0.15 : 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? Colors.white38 : Colors.black.withOpacity(0.38))),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? primaryColor
                        : (isDark ? Colors.white38 : Colors.black.withOpacity(0.38)),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ── Quick stats (top categories) ─────────────────────────────────────────────
  Widget _buildQuickStats(
      BuildContext context, List transactions, bool isDark) {
    final Map<String, double> catData = {};
    for (var t in transactions) {
      if (!t.isIncome) {
        catData[t.category] = (catData[t.category] ?? 0) + t.amount;
      }
    }
    final topCat = catData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          const SizedBox(height: 12),
          if (topCat.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text('No expenses this month',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black.withOpacity(0.38),
                    fontSize: 13,
                  )),
            )
          else
            ...topCat.take(3).map((e) => _buildCategoryBar(context, e.key,
                e.value,
                catData.values.fold(0.0, (a, b) => a + b), isDark)),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(BuildContext context, String name, double amount,
      double total, bool isDark) {
    final pct = total > 0 ? amount / total : 0.0;
    final color = _getCategoryColor(name);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getCategoryIcon(name),
                        color: color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF0F172A),
                      )),
                ],
              ),
              Text('Rs. ${_formatAmount(amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF0F172A),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent header ─────────────────────────────────────────────────────────────
  Widget _buildRecentHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          GestureDetector(
            onTap: () {
              setState(() => _selectedTab = 1);
              _tabController.animateTo(1);
            },
            child: Text('See all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.accentCyan
                      : AppTheme.lightPrimary,
                )),
          ),
        ],
      ),
    );
  }

  // ── Filter chips (History tab) ────────────────────────────────────────────────
  Widget _buildFilterChips(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: ['All', 'Income', 'Expense'].map((type) {
          final isSelected = _filterType == type;
          final primaryColor =
              isDark ? AppTheme.accentCyan : AppTheme.lightPrimary;
          return GestureDetector(
            onTap: () => setState(() => _filterType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(isDark ? 0.15 : 0.1)
                    : (isDark ? AppTheme.darkCard : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : (isDark
                          ? Colors.white.withOpacity(0.1)
                          : const Color(0xFFE2E8F0)),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(type,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? primaryColor
                        : (isDark ? Colors.white54 : Colors.black.withOpacity(0.45)),
                  )),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 56,
              color: isDark ? Colors.white12 : Colors.black.withOpacity(0.12)),
          const SizedBox(height: 16),
          Text('No transactions yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white38 : Colors.black.withOpacity(0.38),
              )),
          const SizedBox(height: 6),
          Text('Tap + to add your first transaction',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white24 : Colors.black.withOpacity(0.26),
              )),
        ],
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────────────────────────────────
  Widget _buildFAB(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AddTransactionScreen()),
        ),
        backgroundColor:
            isDark ? AppTheme.accentCyan : AppTheme.lightPrimary,
        foregroundColor: Colors.white,
        extendedPadding:
            const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50)),
        elevation: 0,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('Add Transaction',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────────
  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getMonthName() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[DateTime.now().month - 1];
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000)
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000)
      return '${(amount / 1000).toStringAsFixed(1)}K';
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
