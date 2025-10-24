class PlaceDetails {
  String? placeId;
  String? thumbnail;
  String? name;
  String? contactTime;
  String? website;
  String? phone;
  String? directionUrl;

  PlaceDetails(
      {this.placeId,
        this.thumbnail,
        this.name,
        this.contactTime,
        this.website,
        this.phone,
        this.directionUrl});

  PlaceDetails.fromJson(Map<String, dynamic> json) {
    placeId = json['place_id'];
    thumbnail = json['thumbnail'];
    name = json['name'];
    contactTime = json['contact_time'];
    website = json['website'];
    phone = json['phone'];
    directionUrl = json['direction_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['place_id'] = placeId;
    data['thumbnail'] = thumbnail;
    data['name'] = name;
    data['contact_time'] = contactTime;
    data['website'] = website;
    data['phone'] = phone;
    data['direction_url'] = directionUrl;
    return data;
  }
}
