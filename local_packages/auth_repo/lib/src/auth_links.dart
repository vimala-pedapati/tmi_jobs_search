class BaseUrl {
  static String mode = "release";
  static String baseUrl = "https://jozc22oz7io7uu6whp4xipwet40jeswt.lambda-url.ap-south-1.on.aws/";

   static void checkDebugMode() {
    assert(() {
      baseUrl = "https://jozc22oz7io7uu6whp4xipwet40jeswt.lambda-url.ap-south-1.on.aws/";
      mode = "debug";
      return true;
    }());
  }
}
  

