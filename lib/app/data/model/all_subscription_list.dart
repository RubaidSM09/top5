class AllSubscriptionList {
  String? status;
  List<Data>? data;

  AllSubscriptionList({this.status, this.data});

  AllSubscriptionList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? price;
  int? durationDays;
  int? placeLimit;
  int? aiLimit;
  int? weatherLimit;
  bool? status;
  String? feature1;
  String? feature2;
  String? feature3;
  String? feature4;
  String? feature5;
  String? feature6;
  String? feature7;
  String? feature8;
  String? feature9;
  String? feature10;
  String? createdAt;
  String? updatedAt;

  Data({
    this.id,
    this.name,
    this.price,
    this.durationDays,
    this.placeLimit,
    this.aiLimit,
    this.weatherLimit,
    this.status,
    this.feature1,
    this.feature2,
    this.feature3,
    this.feature4,
    this.feature5,
    this.feature6,
    this.feature7,
    this.feature8,
    this.feature9,
    this.feature10,
    this.createdAt,
    this.updatedAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    durationDays = json['duration_days'];
    placeLimit = json['place_limit'];
    aiLimit = json['ai_limit'];
    weatherLimit = json['weather_limit'];
    status = json['status'];
    feature1 = json['feature_1'];
    feature2 = json['feature_2'];
    feature3 = json['feature_3'];
    feature4 = json['feature_4'];
    feature5 = json['feature_5'];
    feature6 = json['feature_6'];
    feature7 = json['feature_7'];
    feature8 = json['feature_8'];
    feature9 = json['feature_9'];
    feature10 = json['feature_10'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['duration_days'] = durationDays;
    data['place_limit'] = placeLimit;
    data['ai_limit'] = aiLimit;
    data['weather_limit'] = weatherLimit;
    data['status'] = status;
    data['feature_1'] = feature1;
    data['feature_2'] = feature2;
    data['feature_3'] = feature3;
    data['feature_4'] = feature4;
    data['feature_5'] = feature5;
    data['feature_6'] = feature6;
    data['feature_7'] = feature7;
    data['feature_8'] = feature8;
    data['feature_9'] = feature9;
    data['feature_10'] = feature10;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
