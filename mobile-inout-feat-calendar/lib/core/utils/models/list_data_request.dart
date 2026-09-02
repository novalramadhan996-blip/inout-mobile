class ListDataRequest {
  int? page;
  int? limit;
  int? offset;
  String? search;
  String? sortBy;
  String? orderBy;
  Map<String, dynamic>? filter;

  ListDataRequest({
    this.page,
    this.limit,
    this.offset,
    this.search,
    this.sortBy,
    this.orderBy,
    this.filter,
  });

  ListDataRequest.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    offset = json['offset'];
    search = json['search'];
    sortBy = json['sort'];
    orderBy = json['order'];
    filter = json['filter'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['limit'] = limit;
    data['offset'] = offset;
    data['search'] = search;
    data['sort'] = sortBy;
    data['order'] = orderBy;
    if (filter != null) {
      data['filter'] = filter;
    }
    return data;
  }
}
