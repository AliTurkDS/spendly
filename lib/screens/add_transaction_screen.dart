import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existing; // null = new, non-null = edit mode
  const AddTransactionScreen({super.key, this.existing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController noteController;

  late bool isIncome;
  late DateTime selectedDate;
  late String selectedCategory;

  final List<String> incomeCategories = ['Salary', 'Bonus', 'Other Income'];
  final List<String> expenseCategories = [
    'Food', 'Travel', 'Shopping', 'Billing', 'Entertainment', 'Other'
  ];

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool get isEditMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    titleController = TextEditingController(text: t?.title ?? '');
    amountController =
        TextEditingController(text: t != null ? t.amount.toStringAsFixed(0) : '');
    noteController = TextEditingController();
    isIncome = t?.isIncome ?? false;
    selectedDate = t?.date ?? DateTime.now();
    selectedCategory = t?.category ?? 'Food';

    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    _animController.dispose();
    super.dispose();
  }

  List<String> get currentCategories =>
      isIncome ? incomeCategories : expenseCategories;

  void saveTransaction() {
    final title = titleController.text.trim();
    final amountStr = amountController.text.trim();

    if (title.isEmpty || amountStr.isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (isEditMode) {
      // Update existing record in-place
      widget.existing!
        ..title = title
        ..amount = amount
        ..category = selectedCategory
        ..date = selectedDate
        ..isIncome = isIncome;
      widget.existing!.save();
    } else {
      final box = Hive.box<TransactionModel>('transactions');
      box.add(TransactionModel(
        title: title,
        amount: amount,
        category: selectedCategory,
        date: selectedDate,
        isIncome: isIncome,
      ));
    }

    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.accentRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.accentCyan : AppTheme.lightPrimary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Icon(Icons.arrow_back_rounded,
                size: 18,
                color: isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
        title: Text(
          isEditMode ? 'Edit Transaction' : 'New Transaction',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TYPE TOGGLE
              Container(
                padding: const EdgeInsets.all(4),
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
                    _buildTypeButton(context, false, 'Expense',
                        Icons.arrow_upward_rounded, AppTheme.accentRed, isDark),
                    _buildTypeButton(context, true, 'Income',
                        Icons.arrow_downward_rounded, AppTheme.accentGreen, isDark),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // AMOUNT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: isDark ? Colors.white38 : Colors.black.withOpacity(0.38),
                        )),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Rs.',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white54 : Colors.black.withOpacity(0.38),
                            )),
                        const SizedBox(width: 4),
                        Expanded(
                          child: TextField(
                            controller: amountController,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: -1,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // DETAILS
              _buildSectionLabel('Details', isDark),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    _buildTextField(context, titleController, 'Title',
                        'e.g. Grocery shopping', isDark),
                    _buildDivider(isDark),
                    _buildDatePicker(context, isDark),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // CATEGORY
              _buildSectionLabel('Category', isDark),
              const SizedBox(height: 8),
              _buildCategoryGrid(context, isDark, primaryColor),

              const SizedBox(height: 16),

              // NOTE
              _buildSectionLabel('Note (optional)', isDark),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: TextField(
                  controller: noteController,
                  maxLines: 3,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a note...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white24 : Colors.black.withOpacity(0.26),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    filled: false,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isIncome ? AppTheme.accentGreen : AppTheme.accentRed,
                    foregroundColor: isIncome ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                          isEditMode
                              ? Icons.check_rounded
                              : (isIncome
                                  ? Icons.add_rounded
                                  : Icons.remove_rounded),
                          size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isEditMode
                            ? 'Update Transaction'
                            : (isIncome ? 'Save Income' : 'Save Expense'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(BuildContext context, bool income, String label,
      IconData icon, Color color, bool isDark) {
    final isSelected = isIncome == income;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            isIncome = income;
            selectedCategory =
                income ? incomeCategories[0] : expenseCategories[0];
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected
                      ? color
                      : (isDark ? Colors.white38 : Colors.black.withOpacity(0.38))),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? color
                        : (isDark ? Colors.white38 : Colors.black.withOpacity(0.38)),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: isDark ? Colors.white38 : Colors.black.withOpacity(0.38),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController ctrl,
      String label, String hint, bool isDark) {
    return TextField(
      controller: ctrl,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: InputBorder.none,
        filled: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.black.withOpacity(0.38), fontSize: 13),
        hintStyle: TextStyle(
            color: isDark ? Colors.white24 : Colors.black.withOpacity(0.26), fontSize: 13),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildDatePicker(BuildContext context, bool isDark) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return GestureDetector(
      onTap: _pickDate,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Date',
                style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : Colors.black.withOpacity(0.38))),
            Row(
              children: [
                Text(
                  '${selectedDate.day} ${months[selectedDate.month - 1]} ${selectedDate.year}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.calendar_today_rounded,
                    size: 14,
                    color: isDark ? Colors.white38 : Colors.black.withOpacity(0.38)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(
      BuildContext context, bool isDark, Color primaryColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: currentCategories.map((cat) {
        final isSelected = selectedCategory == cat;
        final color = _getCategoryColor(cat);
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => selectedCategory = cat);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.15)
                  : (isDark ? AppTheme.darkCard : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color
                    : (isDark
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFE2E8F0)),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getCategoryIcon(cat),
                    size: 16,
                    color: isSelected
                        ? color
                        : (isDark ? Colors.white38 : Colors.black.withOpacity(0.38))),
                const SizedBox(width: 6),
                Text(cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? color
                          : (isDark ? Colors.white54 : Colors.black.withOpacity(0.54)),
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
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
