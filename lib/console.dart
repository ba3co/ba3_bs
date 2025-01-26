abstract class Coffee {
  double cost();

  String description();
}

class BasicCoffee implements Coffee {
  @override
  double cost() {
    return 5.0; // Basic coffee cost
  }

  @override
  String description() {
    return 'Basic Coffee';
  }
}

class CoffeeDecorator implements Coffee {
  final Coffee coffee;

  CoffeeDecorator(this.coffee);

  @override
  double cost() {
    return coffee.cost();
  }

  @override
  String description() {
    return coffee.description();
  }
}

class MilkDecorator extends CoffeeDecorator {
  MilkDecorator(super.coffee);

  @override
  double cost() {
    return super.cost() + 1.5; // Add the cost of milk
  }

  @override
  String description() {
    return '${super.description()}, with Milk';
  }
}

class SugarDecorator extends CoffeeDecorator {
  SugarDecorator(super.coffee);

  @override
  double cost() {
    return super.cost() + 0.5; // Add the cost of sugar
  }

  @override
  String description() {
    return '${super.description()}, with Sugar';
  }
}

void main() {
  Coffee coffee = BasicCoffee();
  print('${coffee.description()} costs \$${coffee.cost()}');

  Coffee milkCoffee = MilkDecorator(coffee);
  print('${milkCoffee.description()} costs \$${milkCoffee.cost()}');

  Coffee sugarMilkCoffee = SugarDecorator(milkCoffee);
  print('${sugarMilkCoffee.description()} costs \$${sugarMilkCoffee.cost()}');
}
