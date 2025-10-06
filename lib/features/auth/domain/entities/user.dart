class User {
  final String phoneNumber;
  final int imageInDay;
  final String subscription;
  final String token;
  final int subDaysRemain;

  User({
    required this.phoneNumber,
    required this.imageInDay,
    required this.subscription,
    required this.token,
    required this.subDaysRemain,
  });

  // تبدیل از JSON به User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      phoneNumber: json['phone_number'] as String? ?? '',
      imageInDay: json['image_inday'] as int? ?? 0,
      subscription: json['subscription'] as String? ?? '',
      token: json['token'] as String? ?? '',
      subDaysRemain: json['sub_days_remain'] as int? ?? 0,
    );
  }

  // تبدیل از User به JSON
  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'image_in_day': imageInDay,
      'subscription': subscription,
      'token': token,
      'sub_days_remain': subDaysRemain,
    };
  }
}
