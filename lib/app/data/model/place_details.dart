class PlaceDetails {
  String? placeId;
  String? thumbnail;
  String? name;
  String? contactTime;
  String? website;
  String? phone;

  PlaceDetails(
      {this.placeId,
        this.thumbnail,
        this.name,
        this.contactTime,
        this.website,
        this.phone});

  PlaceDetails.fromJson(Map<String, dynamic> json) {
    placeId = json['place_id'];
    thumbnail = json['thumbnail'];
    name = json['name'];
    contactTime = json['contact_time'];
    website = json['website'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['place_id'] = this.placeId;
    data['thumbnail'] = this.thumbnail;
    data['name'] = this.name;
    data['contact_time'] = this.contactTime;
    data['website'] = this.website;
    data['phone'] = this.phone;
    return data;
  }
}
