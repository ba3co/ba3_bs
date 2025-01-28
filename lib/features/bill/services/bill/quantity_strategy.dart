abstract class QuantityStrategy {
  double calculateQuantity(double baseQuantity);
}

class AddQuantityStrategy implements QuantityStrategy {
  @override
  double calculateQuantity(double baseQuantity) {
    return baseQuantity; // Adds quantity as-is
  }
}

class SubtractQuantityStrategy implements QuantityStrategy {
  @override
  double calculateQuantity(double baseQuantity) {
    return -baseQuantity; // Subtracts quantity
  }
}
