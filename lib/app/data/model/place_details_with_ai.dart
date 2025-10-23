class PlaceDetailsWithAI {
  String? placeId;
  String? name;
  Null priceLevel;
  List<String>? types;
  List<String>? aiSummary;
  AiRatings? aiRatings;

  PlaceDetailsWithAI(
      {this.placeId,
        this.name,
        this.priceLevel,
        this.types,
        this.aiSummary,
        this.aiRatings});

  PlaceDetailsWithAI.fromJson(Map<String, dynamic> json) {
    placeId = json['place_id'];
    name = json['name'];
    priceLevel = json['price_level'];
    types = json['types'].cast<String>();
    aiSummary = json['ai_summary'].cast<String>();
    aiRatings = json['ai_ratings'] != null
        ? new AiRatings.fromJson(json['ai_ratings'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['place_id'] = this.placeId;
    data['name'] = this.name;
    data['price_level'] = this.priceLevel;
    data['types'] = this.types;
    data['ai_summary'] = this.aiSummary;
    if (this.aiRatings != null) {
      data['ai_ratings'] = this.aiRatings!.toJson();
    }
    return data;
  }
}

class AiRatings {
  double? food;
  double? service;
  double? atmosphere;
  int? price;

  AiRatings({this.food, this.service, this.atmosphere, this.price});

  AiRatings.fromJson(Map<String, dynamic> json) {
    food = json['food'];
    service = json['service'];
    atmosphere = json['atmosphere'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['food'] = this.food;
    data['service'] = this.service;
    data['atmosphere'] = this.atmosphere;
    data['price'] = this.price;
    return data;
  }
}
