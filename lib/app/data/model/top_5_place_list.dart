class Top5PlaceList {
  Origin? origin;
  int? count;
  List<Places>? places;

  Top5PlaceList({this.origin, this.count, this.places});

  Top5PlaceList.fromJson(Map<String, dynamic> json) {
    origin = json['origin'] != null ? Origin.fromJson(json['origin']) : null;
    count = _parseInt(json['count']);
    if (json['places'] is List) {
      places = (json['places'] as List)
          .map((v) => Places.fromJson(v as Map<String, dynamic>))
          .toList();
    } else {
      places = <Places>[];
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (origin != null) data['origin'] = origin!.toJson();
    data['count'] = count;
    if (places != null) {
      data['places'] = places!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Origin {
  double? latitude;
  double? longitude;

  Origin({this.latitude, this.longitude});

  Origin.fromJson(Map<String, dynamic> json) {
    latitude = _parseDouble(json['latitude']);
    longitude = _parseDouble(json['longitude']);
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
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
  String? directionUrl;
  List<String>? types;
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
    this.directionUrl,
    this.types,
    this.distanceText,
    this.durationText,
    this.saved,
  });

  factory Places.fromJson(Map<String, dynamic> json) {
    return Places(
      placeId: _parseString(json['place_id']),
      name: _parseString(json['name']),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      rating: _parseDouble(json['rating']),
      reviewsCount: _parseInt(json['reviews_count']),
      thumbnail: _parseString(json['thumbnail']),
      openNow: _parseBool(json['open_now']),
      directionUrl: _parseString(json['direction_url']),
      types: _parseStringList(json['types']),
      distanceText: _parseString(json['distance_text']),
      durationText: _parseString(json['duration_text']),
      saved: _parseInt(json['saved']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['place_id'] = placeId;
    data['name'] = name;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['rating'] = rating;
    data['reviews_count'] = reviewsCount;
    data['thumbnail'] = thumbnail;
    data['open_now'] = openNow;
    data['direction_url'] = directionUrl;
    data['types'] = types;
    data['distance_text'] = distanceText;
    data['duration_text'] = durationText;
    data['saved'] = saved;
    return data;
  }
}

/// ---------- Robust parsers ----------

double? _parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

bool? _parseBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is int) return v == 1;
  if (v is String) {
    final s = v.toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
  }
  return null;
}

String? _parseString(dynamic v) {
  if (v == null) return null;
  return v.toString();
}

List<String>? _parseStringList(dynamic v) {
  if (v == null) return null;
  if (v is List) {
    return v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
  }
  if (v is String && v.isNotEmpty) {
    // handle comma-separated strings (just in case)
    return v.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
  }
  return null;
}
