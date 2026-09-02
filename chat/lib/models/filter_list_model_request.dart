class FilterListModelRequest {
  // int? page;
  int? limit;
  String? search;
  String? sort;
  String? order;
  int? offset;
  FilterData? filter;

  FilterListModelRequest({
    this.limit,
    this.search,
    this.sort,
    this.order,
    this.offset,
    this.filter,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'limit': limit,
      'search': search,
      'sort': sort,
      'order': order,
      'offset': offset,
    };

    if (filter != null && !filter!.isEmpty) {
      data['filter'] = filter!.toJson();
    }

    return data;
  }
}

class FilterData {
  String? organizationId;
  String? employeeId;

  FilterData({this.organizationId, this.employeeId});

  bool get isEmpty => organizationId == null || organizationId!.isEmpty;

  Map<String, dynamic> toJson() {
    return {'organization_id': organizationId, 'employee_id': employeeId};
  }
}
