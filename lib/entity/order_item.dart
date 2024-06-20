class OrderItem {
  final String service;
  final String invoice;
  final int selectedMachine;
  final int selectedPackage;
  final String selectedTimeSlot;
  final String selectedLocation;
  final bool showDeliveryCard;
  final String address;
  final int estimatedCost;
  final int totalCost;
  final String orderType;
  final String status;
  final String date;
  final int progress;

  const OrderItem({
    required this.service,
    required this.invoice,
    required this.selectedMachine,
    required this.selectedPackage,
    required this.selectedTimeSlot,
    required this.selectedLocation,
    required this.showDeliveryCard,
    required this.estimatedCost,
    required this.totalCost,
    required this.address,
    required this.orderType,
    required this.status,
    required this.date,
    required this.progress,
  });
}
