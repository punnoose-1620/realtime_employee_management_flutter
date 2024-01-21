class Values{
  static final Values _instance = Values.init();

  Values.init() {}
  factory Values() {
    return _instance;
  }

  double HEIGHT = 0.0;
  double WIDTH = 0.0;

  List<dynamic> EMP_LIST = [];
  List<String> POSITIONS = ['Produce Designer', 'Flutter Developer', 'QA Tester', 'Product Owner'];

  bool EDIT_EMP_FLAG = false;
  dynamic CURRENT_EMP = {};
}