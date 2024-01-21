class Paths {
  static final Paths _instance = Paths.init();

  Paths.init() {}
  factory Paths() {
    return _instance;
  }

  String EMP_LIST = "/employee_list";
  String ADD_EMP = "/add_employees";

  String ASSETS_FOLDER = "assets/";
}