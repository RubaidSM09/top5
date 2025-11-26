class ActionPlacesDetails {
  List<ActionPlace>? actionPlace;

  ActionPlacesDetails({this.actionPlace});

  ActionPlacesDetails.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      actionPlace = <ActionPlace>[];
      json['data'].forEach((v) {
        actionPlace!.add(new ActionPlace.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> actionPlace = new Map<String, dynamic>();
    if (this.actionPlace != null) {
      actionPlace['data'] = this.actionPlace!.map((v) => v.toJson()).toList();
    }
    return actionPlace;
  }
}

class ActionPlace {
  int? id;
  String? placeId;
  double? latitude;
  double? longitude;
  String? placeName;
  String? image;
  double? rating;
  String? directionsUrl;
  String? phone;
  String? email;
  String? website;
  String? priceCurrency;
  String? activityType;
  bool? isSaved;
  bool? isRecent;
  bool? isReservation;
  String? createdAt;
  String? updatedAt;

  ActionPlace(
      {this.id,
        this.placeId,
        this.latitude,
        this.longitude,
        this.placeName,
        this.image,
        this.rating,
        this.directionsUrl,
        this.phone,
        this.email,
        this.website,
        this.priceCurrency,
        this.activityType,
        this.isSaved,
        this.isRecent,
        this.isReservation,
        this.createdAt,
        this.updatedAt});

  ActionPlace.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    placeId = json['place_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    placeName = json['place_name'];
    image = json['image'];
    rating = json['rating'];
    directionsUrl = json['directions_url'];
    phone = json['phone'];
    email = json['email'];
    website = json['website'];
    priceCurrency = json['price_currency'];
    activityType = json['activity_type'];
    isSaved = json['is_saved'];
    isRecent = json['is_recent'];
    isReservation = json['is_reservation'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> actionPlace = new Map<String, dynamic>();
    actionPlace['id'] = this.id;
    actionPlace['place_id'] = this.placeId;
    actionPlace['latitude'] = this.latitude;
    actionPlace['longitude'] = this.longitude;
    actionPlace['place_name'] = this.placeName;
    actionPlace['image'] = this.image;
    actionPlace['rating'] = this.rating;
    actionPlace['directions_url'] = this.directionsUrl;
    actionPlace['phone'] = this.phone;
    actionPlace['email'] = this.email;
    actionPlace['website'] = this.website;
    actionPlace['price_currency'] = this.priceCurrency;
    actionPlace['activity_type'] = this.activityType;
    actionPlace['is_saved'] = this.isSaved;
    actionPlace['is_recent'] = this.isRecent;
    actionPlace['is_reservation'] = this.isReservation;
    actionPlace['created_at'] = this.createdAt;
    actionPlace['updated_at'] = this.updatedAt;
    return actionPlace;
  }
}
