class RequestSchedule {
  int? page;
  int? limit;
  int? offset;
  String? search;
  String? sortBy;
  String? orderBy;
  String? eventDateStart;
  String? eventDateEnd;
  Map<String, dynamic>? filter;

  RequestSchedule({
    this.page,
    this.limit,
    this.offset,
    this.search,
    this.sortBy,
    this.orderBy,
    this.filter,
    this.eventDateStart,
    this.eventDateEnd,
  });

  RequestSchedule.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    offset = json['offset'];
    search = json['search'];
    sortBy = json['sort'];
    orderBy = json['order'];
    filter = json['filter'];
    eventDateStart = json['event_date_start'];
    eventDateEnd = json['event_date_end'];
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
    data['event_date_start'] = eventDateStart;
    data['event_date_end'] = eventDateEnd;
    return data;
  }
}
