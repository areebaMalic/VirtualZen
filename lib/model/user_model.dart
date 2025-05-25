class UserModel {
  final String id;
  final String name;
  final String pin;
  final bool hideOnlineStatus;
  final String? imageUrl;
  final String? selectedPhobia;
  final bool isDarkMode;

  UserModel({
    required this.id,
    required this.name,
    required this.pin,
    this.hideOnlineStatus = false,
    this.imageUrl,
    this.selectedPhobia,
    this.isDarkMode = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      pin: map['pin'] ?? '',
      hideOnlineStatus: map['hideOnlineStatus'] ?? false,
      imageUrl: map['imageUrl'],
      selectedPhobia: map['selectedPhobia'],
      isDarkMode: map['isDarkMode'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'pin': pin,
      'hideOnlineStatus': hideOnlineStatus,
      'imageUrl': imageUrl,
      'selectedPhobia': selectedPhobia,
      'isDarkMode': isDarkMode,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? pin,
    bool? hideOnlineStatus,
    String? imageUrl,
    String? selectedPhobia,
    bool? isDarkMode,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      pin: pin ?? this.pin,
      hideOnlineStatus: hideOnlineStatus ?? this.hideOnlineStatus,
      imageUrl: imageUrl ?? this.imageUrl,
      selectedPhobia: selectedPhobia ?? this.selectedPhobia,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}