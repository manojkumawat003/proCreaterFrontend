
class User {
  final String id;
  final String name;
  final String email;
  final String role;

  User({required this.id, required this.name, required this.email, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };
}

class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration;

  Service({required this.id, required this.name, required this.description, required this.price, required this.duration});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      duration: json['duration'],
    );
  }
}

class Booking {
  final String id;
  final String userId;
  final String userName;
  final String serviceId;
  final String serviceName;
  final String date;
  final String time;
  final String status;

  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.serviceId,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'] ?? 'Unknown',
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      date: json['date'],
      time: json['time'],
      status: json['status'],
    );
  }
}
