// abstract class Coffee {
//   double cost();
//
//   String description();
// }
//
// class BasicCoffee implements Coffee {
//   @override
//   double cost() {
//     return 5.0; // Basic coffee cost
//   }
//
//   @override
//   String description() {
//     return 'Basic Coffee';
//   }
// }
//
// class CoffeeDecorator implements Coffee {
//   final Coffee coffee;
//
//   CoffeeDecorator(this.coffee);
//
//   @override
//   double cost() {
//     return coffee.cost();
//   }
//
//   @override
//   String description() {
//     return coffee.description();
//   }
// }
//
// class MilkDecorator extends CoffeeDecorator {
//   MilkDecorator(super.coffee);
//
//   @override
//   double cost() {
//     return super.cost() + 1.5; // Add the cost of milk
//   }
//
//   @override
//   String description() {
//     return '${super.description()}, with Milk';
//   }
// }
//
// class SugarDecorator extends CoffeeDecorator {
//   SugarDecorator(super.coffee);
//
//   @override
//   double cost() {
//     return super.cost() + 0.5; // Add the cost of sugar
//   }
//
//   @override
//   String description() {
//     return '${super.description()}, with Sugar';
//   }
// }
//
// void main() {
//   Coffee coffee = BasicCoffee();
//   print('${coffee.description()} costs \$${coffee.cost()}');
//
//   Coffee milkCoffee = MilkDecorator(coffee);
//   print('${milkCoffee.description()} costs \$${milkCoffee.cost()}');
//
//   Coffee sugarMilkCoffee = SugarDecorator(milkCoffee);
//   print('${sugarMilkCoffee.description()} costs \$${sugarMilkCoffee.cost()}');
// }

/// Virtual Proxy
// Step 1: Define the Subject (Interface)
abstract class Image {
  void display(); // Common method for both real and proxy images
}

// Step 2: Create the Real Subject (Expensive Object)
class RealImage implements Image {
  final String filename;

  RealImage(this.filename) {
    _loadFromDisk(); // Simulate expensive loading operation
  }

  void _loadFromDisk() {
    print("Loading image from disk: $filename");
  }

  @override
  void display() {
    print("Displaying image: $filename");
  }
}

// Step 3: Create the Proxy (Placeholder)
class ImageProxy implements Image {
  final String filename;
  RealImage? _realImage; // Lazy initialization of the real image

  ImageProxy(this.filename);

  @override
  void display() {
    _realImage ??= RealImage(filename);
    _realImage!.display();
  }
}

/// Remote Proxy
abstract class RemoteService {
  void fetchData();
}

class RealRemoteService implements RemoteService {
  @override
  void fetchData() {
    print("Fetching data from remote server...");
  }
}

class RemoteServiceProxy implements RemoteService {
  final RealRemoteService _remoteService = RealRemoteService();

  @override
  void fetchData() {
    print("Proxy: Forwarding request to the remote server...");
    _remoteService.fetchData();
  }
}

/// Protection Proxy
abstract class Database {
  void query(String sql);
}

class RealDatabase implements Database {
  @override
  void query(String sql) {
    print("Executing query: $sql");
  }
}

class DatabaseProxy implements Database {
  final String userRole;
  final RealDatabase _realDatabase = RealDatabase();

  DatabaseProxy(this.userRole);

  @override
  void query(String sql) {
    if (userRole == "admin") {
      _realDatabase.query(sql);
    } else {
      print("Access denied: Insufficient permissions.");
    }
  }
}

abstract class WeatherService {
  String getWeather(String city);
}

class RealWeatherService implements WeatherService {
  @override
  String getWeather(String city) {
    print("Fetching weather data for $city...");
    return "Sunny in $city";
  }
}

/// Cache Proxy
class CachedWeatherServiceProxy implements WeatherService {
  final RealWeatherService _realWeatherService = RealWeatherService();
  final Map<String, String> _cache = {};

  @override
  String getWeather(String city) {
    if (_cache.containsKey(city)) {
      print("Returning cached weather for $city...");
      return _cache[city]!;
    }

    print("Fetching new weather data...");
    String result = _realWeatherService.getWeather(city);
    _cache[city] = result;
    return result;
  }
}

/// Firewall Proxy
abstract class WebServer {
  void handleRequest(String ip);
}

class RealWebServer implements WebServer {
  @override
  void handleRequest(String ip) {
    print("Handling request from IP: $ip");
  }
}

class FirewallProxy implements WebServer {
  final RealWebServer _webServer = RealWebServer();
  final List<String> _blockedIps = ["192.168.1.5", "192.168.1.6"];

  @override
  void handleRequest(String ip) {
    if (_blockedIps.contains(ip)) {
      print("Blocked request from IP: $ip");
    } else {
      _webServer.handleRequest(ip);
    }
  }
}

/// Synchronization Proxy
abstract class Counter {
  void increment();

  int get value;
}

class RealCounter implements Counter {
  int _value = 0;

  @override
  void increment() {
    _value++;
  }

  @override
  int get value => _value;
}

class SynchronizedCounterProxy implements Counter {
  final RealCounter _counter = RealCounter();

  @override
  void increment() {
    print("Incrementing counter in a thread-safe way...");
    // Simulate thread-safe operation
    synchronized(() {
      _counter.increment();
    });
  }

  @override
  int get value => _counter.value;

  void synchronized(Function operation) {
    // Placeholder for synchronization
    operation();
  }
}

// Step 4: Client Code
void main() {
  // Virtual Proxy
  print("=== Virtual Proxy ===");
  print("Creating proxy for 'photo1.jpg'...");
  Image image1 = ImageProxy("photo1.jpg");

  print("\nCreating proxy for 'photo2.jpg'...");
  Image image2 = ImageProxy("photo2.jpg");

  print("\nDisplaying 'photo1.jpg'...");
  image1.display(); // Real image is loaded here

  print("\nDisplaying 'photo2.jpg'...");
  image2.display(); // Real image is loaded here

  print("\nDisplaying 'photo1.jpg' again...");
  image1.display(); // Real image is reused without loading

  // Remote Proxy
  print("\n=== Remote Proxy ===");
  RemoteService remoteService = RemoteServiceProxy();
  remoteService.fetchData();

  // Protection Proxy
  print("\n=== Protection Proxy ===");
  Database dbAdmin = DatabaseProxy("admin");
  Database dbUser = DatabaseProxy("user");

  dbAdmin.query("DELETE FROM users"); // Allowed
  dbUser.query("DELETE FROM users"); // Denied

  // Cache Proxy
  print("\n=== Cache Proxy ===");
  WeatherService weatherService = CachedWeatherServiceProxy();

  print(weatherService.getWeather("New York")); // Fetches new data
  print(weatherService.getWeather("New York")); // Returns cached data
  print(weatherService.getWeather("Los Angeles")); // Fetches new data

  // Firewall Proxy
  print("\n=== Firewall Proxy ===");
  WebServer server = FirewallProxy();

  server.handleRequest("192.168.1.5"); // Blocked
  server.handleRequest("192.168.1.10"); // Allowed

  // Synchronization Proxy
  print("\n=== Synchronization Proxy ===");
  Counter counter = SynchronizedCounterProxy();
  counter.increment();
  print("Counter value: ${counter.value}");
}
