class TransactionItemData {
  final bool isIncome;
  final int amount;
  final String description;
  final DateTime createdAt;

  TransactionItemData({
    required this.isIncome,
    required this.amount,
    required this.description,
    required this.createdAt,
  });
}
