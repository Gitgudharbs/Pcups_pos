class Ts {
  int id;
  double total;
  String note;
  int tall;
  int short;
  String date;

  Ts(
      this.id,
      this.total,
      this.tall,
      this.short,
      this.date
     );

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'total': total,
      'tall': tall,
      'short': short,
      'date': date,
    };
    return map;
  }

  Ts.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    total = map['total'];
    tall = map['tall'];
    short = map['short'];
    date = map['date'];
  }

}
