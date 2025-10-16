class TimeDate {
  String? status;
  User? user;
  Data? data;

  TimeDate({this.status, this.user, this.data});

  TimeDate.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? fullName;
  String? email;
  String? phone;
  String? image;

  User({this.id, this.fullName, this.email, this.phone, this.image});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['full_name'];
    email = json['email'];
    phone = json['phone'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['full_name'] = this.fullName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['image'] = this.image;
    return data;
  }
}

class Data {
  String? weather;
  String? weatherDescription;
  String? dayName;
  String? timeStr;
  double? tempCelsius;

  Data(
      {this.weather,
        this.weatherDescription,
        this.dayName,
        this.timeStr,
        this.tempCelsius});

  Data.fromJson(Map<String, dynamic> json) {
    weather = json['weather'];
    weatherDescription = json['weather_description'];
    dayName = json['day_name'];
    timeStr = json['time_str'];
    tempCelsius = json['temp_celsius'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['weather'] = this.weather;
    data['weather_description'] = this.weatherDescription;
    data['day_name'] = this.dayName;
    data['time_str'] = this.timeStr;
    data['temp_celsius'] = this.tempCelsius;
    return data;
  }
}
