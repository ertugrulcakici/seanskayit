import 'dart:developer';

class ExpanseModel {
  String id;
  double amount;
  String date;
  String categoryId;
  String addedBy;

  ExpanseModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.addedBy,
  });

  factory ExpanseModel.fromJson(Map<String, dynamic> json) => ExpanseModel(
        id: json["id"],
        amount: json["amount"].toDouble(),
        date: json["date"],
        categoryId: json["categoryId"],
        addedBy: json["addedBy"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "date": date,
        "categoryId": categoryId,
        "addedBy": addedBy,
      };

  debugPrint() {
    log("ExpanseModel");
    log("id: $id");
    log("amount: $amount");
    log("date: $date");
    log("categoryId: $categoryId");
    log("addedBy: $addedBy");
  }
}
