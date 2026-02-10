class Customer {
  final String id;
  final String name;
  final String? phone;
  final String doorNumber;
  final double latitude;
  final double longitude;
  final List<String> groups;
  final double balance;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    required this.doorNumber,
    required this.latitude,
    required this.longitude,
    required this.groups,
    required this.balance,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'door_number': doorNumber,
      'latitude': latitude,
      'longitude': longitude,
      'groups': groups.join(','),
      'balance': balance,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      doorNumber: map['door_number'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      groups: (map['groups'] as String).split(',').where((g) => g.isNotEmpty).toList(),
      balance: map['balance'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  Customer copyWith({
    String? name,
    String? phone,
    String? doorNumber,
    double? latitude,
    double? longitude,
    List<String>? groups,
    double? balance,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      doorNumber: doorNumber ?? this.doorNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      groups: groups ?? this.groups,
      balance: balance ?? this.balance,
      createdAt: createdAt,
    );
  }
}
