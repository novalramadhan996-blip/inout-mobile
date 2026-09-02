class ListActivityRequestModel {
  String? search;
  String? sort;
  String? order;
  int? offset;
  int? limit;
  Map<String, dynamic>? filter;
  Map<String, dynamic>? fields;

  ListActivityRequestModel({
    this.search,
    this.sort,
    this.order,
    this.offset,
    this.limit,
    this.filter,
    this.fields,
  });

  ListActivityRequestModel.fromJson(Map<String, dynamic> json) {
    search = json['search'];
    sort = json['sort'];
    order = json['order'];
    offset = json['offset'];
    limit = json['limit'];
    filter = json['filter'];
    fields = json['fields'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['search'] = search;
    data['sort'] = sort;
    data['order'] = order;
    data['offset'] = offset;
    data['limit'] = limit;
    if (filter != null) {
      data['filter'] = filter;
    }
    if (fields != null) {
      data['fields'] = fields;
    }
    return data;
  }
}
