import 'dart:convert';

class OrderModel {
  final String id;
  OrderModel(this.id);
  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      OrderModel(json['id'].toString());
}

void main() {
  String jsonStr = '{"orders":[{"id":123}]}';
  var decoded = jsonDecode(jsonStr);
  List<dynamic> orderData = decoded['orders'];

  try {
    var list = orderData.map((e) => OrderModel.fromJson(e)).toList();
    print('Success');
  } catch (e, st) {
    print("error: $e");
    // print('Failed: \');
  }
}
