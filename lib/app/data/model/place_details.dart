class PlaceDetails {
  String? placeId;
  String? name;
  String? website;
  String? phone;

  PlaceDetails({this.placeId, this.name, this.website, this.phone});

  PlaceDetails.fromJson(Map<String, dynamic> json) {
    placeId = json['place_id'];
    name = json['name'];
    website = json['website'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['place_id'] = this.placeId;
    data['name'] = this.name;
    data['website'] = this.website;
    data['phone'] = this.phone;
    return data;
  }
}
