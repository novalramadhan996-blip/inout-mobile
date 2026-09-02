class UserReservation {
  String? date;
  String? guestName;
  String? meetWith;
  String? reservedTime;
  String? checkin;
  String? roomaccess;
  String? checkout;

  UserReservation(
      {this.date,
      this.guestName,
      this.meetWith,
      this.reservedTime,
      this.checkin,
      this.roomaccess,
      this.checkout});

  UserReservation.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    guestName = json['guestName'];
    meetWith = json['meetWith'];
    reservedTime = json['reservedTime'];
    checkin = json['checkin'];
    roomaccess = json['roomaccess'];
    checkout = json['checkout'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['guestName'] = guestName;
    data['meetWith'] = meetWith;
    data['reservedTime'] = reservedTime;
    data['checkin'] = checkin;
    data['roomaccess'] = roomaccess;
    data['checkout'] = checkout;
    return data;
  }
}