import 'package:equatable/equatable.dart';
import 'package:mobile_in_out/core/utils/helper/return_value.dart';

class LocationModel extends Equatable {
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
  final dynamic area;
  final dynamic attributes;
  final String? descr;
  final int? active;
  final String? appsId;
  final String? created;
  final String? createdBy;
  final String? updated;
  final String? updatedBy;

  const LocationModel({
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
    this.createdBy,
    this.updated,
    this.updatedBy,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      locationId: ReturnValue.string(map['location_id']),
      locationName: ReturnValue.string(map['location_name']),
      address: ReturnValue.string(map['address']),
      province: ReturnValue.string(map['province']),
      city: ReturnValue.string(map['city']),
      country: ReturnValue.string(map['country']),
      zipcode: ReturnValue.string(map['zipcode']),
      latitude: ReturnValue.doubleValue(map['latitude']),
      longitude: ReturnValue.doubleValue(map['longitude']),
      radius: ReturnValue.doubleValue(map['radius']),
      area: map['area'],
      attributes: map['attributes'],
      descr: ReturnValue.string(map['descr']),
      active: ReturnValue.integer(map['active']),
      appsId: ReturnValue.string(map['apps_id']),
      created: ReturnValue.string(map['created']),
      createdBy: ReturnValue.string(map['createdby']),
      updated: ReturnValue.string(map['updated']),
      updatedBy: ReturnValue.string(map['updatedby']),
    );
  }

  static List<LocationModel> fromList(List<dynamic> data) {
    return data.map((e) => LocationModel.fromMap(e)).toList();
  }

  LocationModel copyWith({
    String? locationId,
    String? locationName,
    String? address,
    String? province,
    String? city,
    String? country,
    String? zipcode,
    double? latitude,
    double? longitude,
    double? radius,
    dynamic area,
    dynamic attributes,
    String? descr,
    int? active,
    String? appsId,
    String? created,
    String? createdBy,
    String? updated,
    String? updatedBy,
  }) {
    return LocationModel(
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      address: address ?? this.address,
      province: province ?? this.province,
      city: city ?? this.city,
      country: country ?? this.country,
      zipcode: zipcode ?? this.zipcode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      area: area ?? this.area,
      attributes: attributes ?? this.attributes,
      descr: descr ?? this.descr,
      active: active ?? this.active,
      appsId: appsId ?? this.appsId,
      created: created ?? this.created,
      createdBy: createdBy ?? this.createdBy,
      updated: updated ?? this.updated,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
    locationId,
    locationName,
    address,
    province,
    city,
    country,
    zipcode,
    latitude,
    longitude,
    radius,
    area,
    attributes,
    descr,
    active,
    appsId,
    created,
    createdBy,
    updated,
    updatedBy,
  ];
}
