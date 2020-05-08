class Report {
  String day;
  double total;
  int tall;
  int short;
  int transactions;

  Report(this.day, this.total, this.tall, this.short, this.transactions);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'day': day,
      'total': total,
      'tall': tall,
      'short': short,
      'transactions': transactions,
    };
    return map;
  }

  Report.fromMap(Map<String, dynamic> map) {
    day = map['day'];
    total = map['total'];
    tall = map['tall'];
    short = map['short'];
    transactions = map['transactions'];
  }
}
