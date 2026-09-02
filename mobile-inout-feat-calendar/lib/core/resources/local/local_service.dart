import 'dart:io';
import 'package:mobile_in_out/core/utils/models/check_in/check_in_response_model.dart';
import 'package:mobile_in_out/core/utils/models/check_out/check_out_response_model.dart';
import 'package:mobile_in_out/core/utils/models/profile_model.dart';
import 'package:logger/web.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 2;
  static const table = 'profile';
  static const tableCheckIn = 'check_in';
  static const tableCheckOut = 'check_out';
  static const columnId = 'id';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static late Database _database;
  Future<Database> get database async {
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        account_id TEXT,
        name TEXT,
        user_id TEXT,
        id_card TEXT,
        email TEXT,
        phone TEXT,
        birthdate TEXT,
        gender TEXT,
        active INTEGER,
        account_type_id TEXT,
        created TEXT,
        updated TEXT,
        unit_usaha TEXT,
        working_time_in TEXT,
        working_time_out TEXT,
        unit_kerja TEXT,
        model_data TEXT,
        location_id TEXT,
        absensi TEXT,
        profile_url TEXT,
        photo TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCheckIn (
        attendance_id TEXT,
        employee_id TEXT,
        employee_name TEXT,
        job_title TEXT,
        organization_id TEXT,
        organization_name TEXT,
        working_location_id TEXT,
        working_location_name TEXT,
        working_location_address TEXT,
        working_latitude REAL,
        working_longitude REAL,
        working_time_in TEXT,
        working_time_out TEXT,
        device_id TEXT,
        device_info TEXT,
        date_in TEXT,
        date_out TEXT,
        time_in TEXT,
        time_out TEXT,
        status TEXT,
        latitude_in REAL,
        longitude_in REAL,
        address_in TEXT,
        latitude_out REAL,
        longitude_out REAL,
        address_out TEXT,
        note_in TEXT,
        note_out TEXT,
        photo_in_url TEXT,
        photo_out_url TEXT,
        face_in_url TEXT,
        face_out_url TEXT,
        radius_in INTEGER,
        radius_out INTEGER,
        diff_time_in INTEGER,
        diff_time_out INTEGER,
        apps_id TEXT,
        created TEXT,
        createdby TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCheckOut (
        attendance_id TEXT,
        nrp TEXT,
        account_id TEXT,
        device_id TEXT,
        device_info TEXT,
        time_out TEXT,
        status TEXT,
        latitude_out TEXT,
        longitude_out TEXT,
        address_out TEXT,
        note_out TEXT,
        created TEXT,
        descr_type_out TEXT,
        timezone_out TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS $tableCheckIn');
      await db.execute('''
        CREATE TABLE $tableCheckIn (
          attendance_id TEXT,
          employee_id TEXT,
          employee_name TEXT,
          job_title TEXT,
          organization_id TEXT,
          organization_name TEXT,
          working_location_id TEXT,
          working_location_name TEXT,
          working_location_address TEXT,
          working_latitude REAL,
          working_longitude REAL,
          working_time_in TEXT,
          working_time_out TEXT,
          device_id TEXT,
          device_info TEXT,
          date_in TEXT,
          date_out TEXT,
          time_in TEXT,
          time_out TEXT,
          status TEXT,
          latitude_in REAL,
          longitude_in REAL,
          address_in TEXT,
          latitude_out REAL,
          longitude_out REAL,
          address_out TEXT,
          note_in TEXT,
          note_out TEXT,
          photo_in_url TEXT,
          photo_out_url TEXT,
          face_in_url TEXT,
          face_out_url TEXT,
          radius_in INTEGER,
          radius_out INTEGER,
          diff_time_in INTEGER,
          diff_time_out INTEGER,
          apps_id TEXT,
          created TEXT,
          createdby TEXT
        )
      ''');
    }
  }

  Future<int> insert(ProfileModel user) async {
    Database db = await instance.database;
    Logger().d(user.toJson());
    return await db.insert(table, user.toJson(saveLocation: false));
  }

  Future<int> insertCheckIn(CheckInResponseModel checkIn) async {
    Database db = await instance.database;
    Logger().d(checkIn.toJson());
    return await db.insert(tableCheckIn, checkIn.toJson());
  }

  Future<int> insertCheckOut(CheckOutResponseModel checkOut) async {
    Database db = await instance.database;
    Logger().d(checkOut.toJson());
    return await db.insert(tableCheckIn, checkOut.toJson());
  }

  Future<int> deleteCheckInOut() async {
    Database db = await instance.database;
    final List<int> results = await Future.wait([
      db.delete(tableCheckIn),
      db.delete(tableCheckOut),
    ]);

    return results.first;
  }

  Future<List<CheckInResponseModel>> queryAllCheckIn() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> checkIn = await db.query(tableCheckIn);
    Logger().d(checkIn);
    return checkIn.map((u) => CheckInResponseModel.fromJson(u)).toList();
  }

  Future<List<ProfileModel>> queryAllUsers() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> users = await db.query(table);
    Logger().d(users);
    return users.map((u) => ProfileModel.fromJson(u)).toList();
  }

  Future<int> deleteProfile() async {
    Database db = await instance.database;
    return await db.delete(table);
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }
}
