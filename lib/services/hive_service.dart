import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class HiveService {

  static const String boxName = 'transactions';

  // GET BOX
  static Box<TransactionModel> getBox() {
    return Hive.box<TransactionModel>(boxName);
  }

  // ADD TRANSACTION
  static void addTransaction(TransactionModel transaction) {
    final box = getBox();
    box.add(transaction);
  }

  // DELETE TRANSACTION
  static void deleteTransaction(int index) {
    final box = getBox();
    box.deleteAt(index);
  }

  // GET ALL TRANSACTIONS
  static List<TransactionModel> getTransactions() {
    final box = getBox();
    return box.values.toList();
  }
}