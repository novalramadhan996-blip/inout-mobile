/// Global configuration untuk menentukan env file yang digunakan
class AppConfig {
  static String envFileName = ".env";

  static void setEnvFileName(String fileName) {
    envFileName = fileName;
  }
}
