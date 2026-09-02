import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/utils/models/chat_models.dart';
import 'package:mobile_in_out/core/utils/models/user_reservations_models.dart';

class ListOf {
  static List<Chat> chat = [
    Chat(
        name: "System Generated",
        message: "Your guests for meetings at 15:00 have arrived",
        imageUrl: Assets.image1,
        time: "14:45",
        onStatus: false),
    Chat(
        name: "Lisa Amelia Andalusia",
        message: "Pak Rudi dari PT. Sejahtera menunggu di Lobby",
        imageUrl: Assets.image2,
        time: "14:50",
        onStatus: true),
    Chat(
        name: "Tamara Sumargo",
        message: "Lunch yuk",
        imageUrl: Assets.image3,
        time: "14.45",
        onStatus: true),
    Chat(
        name: "Dodi Hendrawan",
        message: "Dokumen penawaran sudah di submit ke pak Jon",
        imageUrl: Assets.image4,
        time: "13:00",
        onStatus: true),
    Chat(
        name: "Citra Lestari",
        message: "Meeting di undur ke jam 4 sore",
        imageUrl: Assets.image5,
        time: "11:45",
        onStatus: true),
    Chat(
        name: "Asri Bonita",
        message: "Segera akan di follow up untuk event minggu depan",
        imageUrl: Assets.image6,
        time: "10:07",
        onStatus: true),
    Chat(
        name: "Hartono",
        message: "Pemintaan pak Rudi untuk segera disampaikan penawara....",
        imageUrl: Assets.image7,
        time: "14:47",
        onStatus: true),
    Chat(
        name: "Lisa Amelia Andalusia",
        message: "Pak Rudi dari PT. Sejahtera menunggu di Lobby",
        imageUrl: Assets.image2,
        time: "14:50",
        onStatus: true),
    Chat(
        name: "Tamara Sumargo",
        message: "Lunch yuk",
        imageUrl: Assets.image3,
        time: "14.45",
        onStatus: true),
    Chat(
        name: "Dodi Hendrawan",
        message: "Dokumen penawaran sudah di submit ke pak Jon",
        imageUrl: Assets.image4,
        time: "13:00",
        onStatus: true),
    Chat(
        name: "Citra Lestari",
        message: "Meeting di undur ke jam 4 sore",
        imageUrl: Assets.image5,
        time: "11:45",
        onStatus: true),
    Chat(
        name: "Asri Bonita",
        message: "Segera akan di follow up untuk event minggu depan",
        imageUrl: Assets.image6,
        time: "10:07",
        onStatus: true),
    Chat(
        name: "Hartono",
        message: "Pemintaan pak Rudi untuk segera disampaikan penawara....",
        imageUrl: Assets.image7,
        time: "14:47",
        onStatus: true),
  ];

  static List<UserReservation> dataUserReservation = [
    UserReservation(
        date: "Thu, Mar 07, 2024",
        guestName: "Rudi Tjahyadi",
        meetWith: "Nina Adelina",
        reservedTime: "15:00",
        checkin: "15:00",
        roomaccess:
            "303 Lobby, Cafetaria 1, Cafetaria 2 Auditorium 1 Elevator 1, Elevator 2",
        checkout: "-"),
    UserReservation(
        date: "Thu, Mar 07, 2024",
        guestName: "Bella Kartika",
        meetWith: "Tamara Sumargo",
        reservedTime: "10:00",
        checkin: "10.00",
        roomaccess: "207 Lobby Elevator 1",
        checkout: "-"),
    UserReservation(
        date: "Thu, Mar 07, 2024",
        guestName: "Suwarno Hadi",
        meetWith: "Citra Lestari",
        reservedTime: "13:00",
        checkin: "13:00",
        roomaccess: "Lobby",
        checkout: "-"),
    UserReservation(
        date: "Thu, Mar 07, 2024",
        guestName: "Hartono Idur",
        meetWith: "Dodi Hendrawan",
        reservedTime: "09:00",
        checkin: "09.00",
        roomaccess: "511 Lobby, Cafetaria 1 Auditorium 1 Elevator 3",
        checkout: "-"),
  ];
}
