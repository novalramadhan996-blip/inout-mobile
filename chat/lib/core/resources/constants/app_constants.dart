class AppConstants {
  static const String baseUrl =
      "https://restapi.inoutapp.org"; // url production
  static const String baseGoogleMapUrl = "https://maps.googleapis.com";
  static const String googleAPiKey = "AIzaSyDs_YJEqyaAlKaFH-XaMyp8L6Hua7U05D0";
  static const String baseUrlMock = "http://localhost:3001";
  static const List<String> listUrlWithoutToken = [
    '/auth-rest/login/mobile',
    '/auth-rest/signup',
    '/auth-rest/refreshtoken',
    '/auth-rest/requestresetpassword',
    '/auth-rest/resetpasswordverification',
  ];

  //type Chat
  static const String typeChatPrivate = "private";
  static const String typeChatGroup = "group";
  //type Message
  static const String typeMessageImage = 'image';
  static const String typeMessageFile = 'file';
  static const String typeMessagetext = 'text';
  static const String typeMessageVideo = 'video';
  //default data
  static const int limitLoadData = 10;
}
