class Top5PlaceList {
  Origin? origin;
  int? count;
  List<Places>? places;

  Top5PlaceList({this.origin, this.count, this.places});

  Top5PlaceList.fromJson(Map<String, dynamic> json) {
    origin =
    json['origin'] != null ? new Origin.fromJson(json['origin']) : null;
    count = json['count'];
    if (json['places'] != null) {
      places = <Places>[];
      json['places'].forEach((v) {
        places!.add(new Places.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.origin != null) {
      data['origin'] = this.origin!.toJson();
    }
    data['count'] = this.count;
    if (this.places != null) {
      data['places'] = this.places!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Origin {
  double? latitude;
  double? longitude;

  Origin({this.latitude, this.longitude});

  Origin.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}

class Places {
  String? placeId;
  String? name;
  double? latitude;
  double? longitude;
  double? rating;
  int? reviewsCount;
  String? thumbnail;
  bool? openNow;
  String? distanceText;
  String? durationText;
  int? saved;

  Places({
    this.placeId,
    this.name,
    this.latitude,
    this.longitude,
    this.rating,
    this.reviewsCount,
    this.thumbnail,
    this.openNow,
    this.distanceText,
    this.durationText,
    this.saved,
  });

  factory Places.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Places(
      placeId: json['place_id']?.toString(),
      name: json['name']?.toString(),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      rating: parseDouble(json['rating']),
      reviewsCount: json['reviews_count'] is int
          ? json['reviews_count']
          : int.tryParse(json['reviews_count']?.toString() ?? ''),
      thumbnail: json['thumbnail']?.toString(),
      openNow: json['open_now'] == true || json['open_now'] == 1,
      distanceText: json['distance_text']?.toString(),
      durationText: json['duration_text']?.toString(),
      saved: json['saved'] is int
          ? json['saved']
          : int.tryParse(json['saved']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['place_id'] = this.placeId;
    data['name'] = this.name;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['rating'] = this.rating;
    data['reviews_count'] = this.reviewsCount;
    data['thumbnail'] = this.thumbnail;
    data['open_now'] = this.openNow;
    data['distance_text'] = this.distanceText;
    data['duration_text'] = this.durationText;
    data['saved'] = this.saved;
    return data;
  }
}
