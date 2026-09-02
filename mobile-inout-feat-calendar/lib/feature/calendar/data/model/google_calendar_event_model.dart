class GoogleCalendarEventModel {
  String? kind;
  String? etag;
  String? summary;
  String? description;
  String? updated;
  String? timeZone;
  String? accessRole;
  List<CalendarEventItem>? items;

  GoogleCalendarEventModel({
    this.kind,
    this.etag,
    this.summary,
    this.description,
    this.updated,
    this.timeZone,
    this.accessRole,
    this.items,
  });

  factory GoogleCalendarEventModel.fromJson(Map<String, dynamic> json) {
    return GoogleCalendarEventModel(
      kind: json['kind'] as String?,
      etag: json['etag'] as String?,
      summary: json['summary'] as String?,
      description: json['description'] as String?,
      updated: json['updated'] as String?,
      timeZone: json['timeZone'] as String?,
      accessRole: json['accessRole'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => CalendarEventItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'etag': etag,
      'summary': summary,
      'description': description,
      'updated': updated,
      'timeZone': timeZone,
      'accessRole': accessRole,
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }
}

class CalendarEventItem {
  String? kind;
  String? etag;
  String? id;
  String? status;
  String? htmlLink;
  String? created;
  String? updated;
  String? summary;
  String? description;
  EventDateTime? start;
  EventDateTime? end;
  String? transparency;
  String? visibility;
  String? iCalUID;
  int? sequence;
  String? eventType;

  CalendarEventItem({
    this.kind,
    this.etag,
    this.id,
    this.status,
    this.htmlLink,
    this.created,
    this.updated,
    this.summary,
    this.description,
    this.start,
    this.end,
    this.transparency,
    this.visibility,
    this.iCalUID,
    this.sequence,
    this.eventType,
  });

  factory CalendarEventItem.fromJson(Map<String, dynamic> json) {
    return CalendarEventItem(
      kind: json['kind'] as String?,
      etag: json['etag'] as String?,
      id: json['id'] as String?,
      status: json['status'] as String?,
      htmlLink: json['htmlLink'] as String?,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
      summary: json['summary'] as String?,
      description: json['description'] as String?,
      start: json['start'] != null
          ? EventDateTime.fromJson(json['start'] as Map<String, dynamic>)
          : null,
      end: json['end'] != null
          ? EventDateTime.fromJson(json['end'] as Map<String, dynamic>)
          : null,
      transparency: json['transparency'] as String?,
      visibility: json['visibility'] as String?,
      iCalUID: json['iCalUID'] as String?,
      sequence: json['sequence'] as int?,
      eventType: json['eventType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'etag': etag,
      'id': id,
      'status': status,
      'htmlLink': htmlLink,
      'created': created,
      'updated': updated,
      'summary': summary,
      'description': description,
      'start': start?.toJson(),
      'end': end?.toJson(),
      'transparency': transparency,
      'visibility': visibility,
      'iCalUID': iCalUID,
      'sequence': sequence,
      'eventType': eventType,
    };
  }

  DateTime? get startDate {
    if (start?.date != null) {
      return DateTime.tryParse(start!.date!);
    }
    if (start?.dateTime != null) {
      return DateTime.tryParse(start!.dateTime!);
    }
    return null;
  }

  DateTime? get endDate {
    if (end?.date != null) {
      return DateTime.tryParse(end!.date!);
    }
    if (end?.dateTime != null) {
      return DateTime.tryParse(end!.dateTime!);
    }
    return null;
  }
}

class EventDateTime {
  String? date;
  String? dateTime;
  String? timeZone;

  EventDateTime({this.date, this.dateTime, this.timeZone});

  factory EventDateTime.fromJson(Map<String, dynamic> json) {
    return EventDateTime(
      date: json['date'] as String?,
      dateTime: json['dateTime'] as String?,
      timeZone: json['timeZone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'dateTime': dateTime, 'timeZone': timeZone};
  }
}
