class MapUrls {
  MapsUrls? mapsUrls;

  MapUrls({this.mapsUrls});

  MapUrls.fromJson(Map<String, dynamic> json) {
    mapsUrls = json['maps_urls'] != null
        ? new MapsUrls.fromJson(json['maps_urls'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mapsUrls != null) {
      data['maps_urls'] = this.mapsUrls!.toJson();
    }
    return data;
  }
}

class MapsUrls {
  String? chIJKcnKUGx6UTcRXdJlJWCrQX0;
  String? chIJExffv3J6UTcR9oWvwsEZQ;

  MapsUrls({this.chIJKcnKUGx6UTcRXdJlJWCrQX0, this.chIJExffv3J6UTcR9oWvwsEZQ});

  MapsUrls.fromJson(Map<String, dynamic> json) {
    chIJKcnKUGx6UTcRXdJlJWCrQX0 = json['ChIJKcnKUGx6UTcRXdJlJWCrQX0'];
    chIJExffv3J6UTcR9oWvwsEZQ = json['ChIJExffv3J6UTcR_9o_WvwsEZQ'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ChIJKcnKUGx6UTcRXdJlJWCrQX0'] = this.chIJKcnKUGx6UTcRXdJlJWCrQX0;
    data['ChIJExffv3J6UTcR_9o_WvwsEZQ'] = this.chIJExffv3J6UTcR9oWvwsEZQ;
    return data;
  }
}
