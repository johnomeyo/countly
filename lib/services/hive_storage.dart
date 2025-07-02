import 'package:countly/models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TransactionStorage {
  static const String _boxName = 'transactions'; // Name of your Hive box
  late Box<Transaction> _transactionBox;

  // Private constructor
  TransactionStorage._();

  // Singleton instance
  static final TransactionStorage _instance = TransactionStorage._();

  // Factory constructor to return the singleton instance
  factory TransactionStorage() {
    return _instance;
  }

  // Initialize the box (call this once, e.g., in main or before first use)
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _transactionBox = await Hive.openBox<Transaction>(_boxName);
    } else {
      _transactionBox = Hive.box<Transaction>(_boxName);
    }
  }

  // --- CRUD Operations ---

  // C (Create/Add)
  Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.add(transaction);
  }

  // C (Create/Add) with a specific key (useful if you need direct access by ID)
  Future<void> putTransaction(String key, Transaction transaction) async {
    await _transactionBox.put(key, transaction);
  }

  // R (Read All)
  List<Transaction> getAllTransactions() {
    return _transactionBox.values.toList();
  }

  // R (Read by Key - useful if you used put with a key)
  Transaction? getTransaction(dynamic key) {
    return _transactionBox.get(key);
  }

  // R (Stream of Transactions - for real-time UI updates)
  Stream<List<Transaction>> get transactionsStream {
    return _transactionBox.watch().map(
      (event) => _transactionBox.values.toList(),
    );
  }

  // U (Update - by index)
  // HiveObjects can be updated directly if they are retrieved from the box.
  // This method is for demonstration if you want to replace an item at an index.
  Future<void> updateTransactionAtIndex(
    int index,
    Transaction updatedTransaction,
  ) async {
    if (index >= 0 && index < _transactionBox.length) {
      await _transactionBox.putAt(index, updatedTransaction);
    } else {
      throw RangeError('Index out of bounds for updating transaction.');
    }
  }

  // U (Update - by key)
  // If you store transactions with explicit keys, you can update them this way.
  // If using `add`, Hive assigns integer keys, so `putAt` or retrieving and saving the object are options.
  Future<void> updateTransactionByKey(
    dynamic key,
    Transaction updatedTransaction,
  ) async {
    if (_transactionBox.containsKey(key)) {
      await _transactionBox.put(key, updatedTransaction);
    } else {
      throw ArgumentError('No transaction found with key: $key');
    }
  }

  // D (Delete - by index)
  Future<void> deleteTransactionAtIndex(int index) async {
    if (index >= 0 && index < _transactionBox.length) {
      await _transactionBox.deleteAt(index);
    } else {
      throw RangeError('Index out of bounds for deleting transaction.');
    }
  }

  // D (Delete - by key)
  Future<void> deleteTransactionByKey(dynamic key) async {
    await _transactionBox.delete(key);
  }

  // D (Delete All)
  Future<void> clearAllTransactions() async {
    await _transactionBox.clear();
  }

  // Close the box (important to call when app closes or box is no longer needed)
  Future<void> close() async {
    if (_transactionBox.isOpen) {
      await _transactionBox.close();
    }
  }
}
