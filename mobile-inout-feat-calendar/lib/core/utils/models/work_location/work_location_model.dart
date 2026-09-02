class LocationResponse {
  final int rcode;
  final dynamic rmessage;
  final List<Location> rows;
  final int total;

  LocationResponse({
    required this.rcode,
    required this.rmessage,
    required this.rows,
    required this.total,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      rcode: json['rcode'],
      rmessage: json['rmessage'],
      rows: (json['rows'] as List).map((i) => Location.fromJson(i)).toList(),
      total: json['total'],
    );
  }
}

class Location {
  final String? locationId;
  final String? locationName;
  final String? address;
  final String? province;
  final String? city;
  final String? country;
  final String? zipCode;
  final double? latitude;
  final double? longitude;
  final double? radius;
  final String? area;
  final String? attributes;
  final String? descr;
  final String? created;

  Location({
    this.locationId,
    this.locationName,
    this.address,
    this.province,
    this.city,
    this.country,
    this.zipCode,
    this.latitude,
    this.longitude,
    this.radius,
    this.area,
    this.attributes,
    this.descr,
    this.created,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      locationId: json['location_id'],
      locationName: json['location_name'],
      address: json['address'],
      province: json['province'],
      city: json['city'],
      country: json['country'],
      zipCode: json['zipcode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      area: json['area'],
      attributes: json['attributes'],
      descr: json['descr'],
      created: json['created'],
    );
  }
}