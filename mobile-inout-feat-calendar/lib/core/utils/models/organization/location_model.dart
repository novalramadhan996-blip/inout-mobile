class Location {
  final String? locationId;
  final String? locationName;
  final String? address;
  final String? province;
  final String? city;
  final String? country;
  final String? zipcode;
  final double? latitude;
  final double? longitude;
  final double? radius;
  final String? descr;
  final int? active;

  Location({
    this.locationId,
    this.locationName,
    this.address,
    this.province,
    this.city,
    this.country,
    this.zipcode,
    this.latitude,
    this.longitude,
    this.radius,
    this.descr,
    this.active,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      locationId: json["location_id"],
      locationName: json["location_name"],
      address: json["address"],
      province: json["province"],
      city: json["city"],
      country: json["country"],
      zipcode: json["zipcode"],
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
      radius: (json["radius"] as num?)?.toDouble(),
      descr: json["descr"],
      active: json["active"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "location_id": locationId,
      "location_name": locationName,
      "address": address,
      "province": province,
      "city": city,
      "country": country,
      "zipcode": zipcode,
      "latitude": latitude,
      "longitude": longitude,
      "radius": radius,
      "descr": descr,
      "active": active,
    };
  }
}
