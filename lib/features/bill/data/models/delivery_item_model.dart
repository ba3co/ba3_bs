class DeliveryItem {
  final String name;
  final int quantity;
  final double price;

  DeliveryItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
class DeliveryModel {
  final String recipientName;
  final String phone;
  final String address;
  final String orderId;
  final DateTime orderDate;
  final List<DeliveryItem> items;

  DeliveryModel({
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.orderId,
    required this.items,
    required this.orderDate,
  });
}