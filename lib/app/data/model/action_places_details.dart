class ActionPlacesDetails {
  List<ActionPlace>? places;

  ActionPlacesDetails({this.places});

  ActionPlacesDetails.fromJson(Map<String, dynamic> json) {
    if (json['places'] is List) {
      places = (json['places'] as List)
          .map((e) => ActionPlace.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      places = <ActionPlace>[];
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (places != null) {
      data['places'] = places!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class ActionPlace {
  String? placeId;
  double? latitude;   // NEW
  double? longitude;  // NEW
  String? name;
  String? photo;
  double? rating;
  bool? openNow;
  String? website;
  String? phone;
  String? distanceText;
  String? durationText;
  String? mapUrl;

  ActionPlace({
    this.placeId,
    this.latitude,   // NEW
    this.longitude,  // NEW
    this.name,
    this.photo,
    this.rating,
    this.openNow,
    this.website,
    this.phone,
    this.distanceText,
    this.durationText,
    this.mapUrl,
  });

  factory ActionPlace.fromJson(Map<String, dynamic> json) {
    return ActionPlace(
      placeId: _s(json['place_id']),
      latitude: _d(json['latitude']),     // NEW
      longitude: _d(json['longitude']),   // NEW
      name: _s(json['name']),
      photo: _s(json['photo']),
      rating: _d(json['rating']),
      openNow: _b(json['open_now']),
      website: _s(json['website']),
      phone: _s(json['phone']),
      distanceText: _s(json['distance_text']),
      durationText: _s(json['duration_text']),
      mapUrl: _s(json['map_url']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'latitude': latitude,     // NEW
      'longitude': longitude,   // NEW
      'name': name,
      'photo': photo,
      'rating': rating,
      'open_now': openNow,
      'website': website,
      'phone': phone,
      'distance_text': distanceText,
      'duration_text': durationText,
      'map_url': mapUrl,
    };
  }
}

/// helpers
String? _s(dynamic v) => v == null ? null : v.toString();
double? _d(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}
bool? _b(dynamic v) {
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
