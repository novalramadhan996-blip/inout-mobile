class WorkingLocation {
  String? locationId;
  String? locationName;
  String? address;
  String? province;
  String? city;
  String? country;
  String? zipcode;
  double? latitude;
  double? longitude;
  double? radius;
  String? area;
  String? attributes;
  String? descr;
  int? active;
  String? appsId;
  String? created;
  String? createdby;
  String? updated;
  String? updatedby;

  WorkingLocation({
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
    this.area,
    this.attributes,
    this.descr,
    this.active,
    this.appsId,
    this.created,
    this.createdby,
    this.updated,
    this.updatedby,
  });

  factory WorkingLocation.fromJson(Map<String, dynamic> json) {
    return WorkingLocation(
      locationId: json["location_id"],
      locationName: json["location_name"],
      address: json["address"],
      province: json["province"],
      city: json["city"],
      country: json["country"],
      zipcode: json["zipcode"],
      latitude: json["latitude"]?.toDouble(),
      longitude: json["longitude"]?.toDouble(),
      radius: json["radius"]?.toDouble(),
      area: json["area"],
      attributes: json["attributes"],
      descr: json["descr"],
      active: json["active"],
      appsId: json["apps_id"],
      created: json["created"],
      createdby: json["createdby"],
      updated: json["updated"],
      updatedby: json["updatedby"],
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
      "area": area,
      "attributes": attributes,
      "descr": descr,
      "active": active,
      "apps_id": appsId,
      "created": created,
      "createdby": createdby,
      "updated": updated,
      "updatedby": updatedby,
    };
  }
}
