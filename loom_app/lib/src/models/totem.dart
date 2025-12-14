class Totem {
  const Totem({
    required this.id,
    required this.name,
    required this.description,
    required this.signalStrength,
    this.wifiSsid,
    this.wifiPassword,
  });

  final String id;
  final String name;
  final String description;
  final int signalStrength;

  final String? wifiSsid;
  final String? wifiPassword;
}
