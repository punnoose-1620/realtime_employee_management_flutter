class CustomFunctions{
  static final CustomFunctions _instance = CustomFunctions.init();

  CustomFunctions.init() {}
  factory CustomFunctions() {
    return _instance;
  }

  String get_expanded_date_as_string(DateTime? datetime) {
    String returnVal = "";
    if(datetime!=null) {
      String month = "";
      switch(datetime.month) {
        case 1 : month = "Jan"; break;
        case 2 : month = "Feb"; break;
        case 3 : month = "March"; break;
        case 4 : month = "April"; break;
        case 5 : month = "May"; break;
        case 6 : month = "June"; break;
        case 7 : month = "July"; break;
        case 8 : month = "Aug"; break;
        case 9 : month = "Sept"; break;
        case 10 : month = "Oct"; break;
        case 11 : month = "Nov"; break;
        case 12 : month = "Dec"; break;
        default : month = "Unknown"; break;
      }
      returnVal = "${datetime.day} $month, ${datetime.year}";
    }
    return returnVal;
  }

  DateTime get_next_date(int day) {
    int end = 31;
    if(DateTime.now().month==4 || DateTime.now().month==6 || DateTime.now().month==9 || DateTime.now().month==11) {
      end = 30;
    }
    if(DateTime.now().month==2) {
      end = 28;
    }
    for(var i=DateTime.now().day+1; i<end;++i) {
      var testDate = DateTime(DateTime.now().year, DateTime.now().month, i);
      if(testDate.weekday==day) {
        return DateTime(DateTime.now().year, DateTime.now().month, i);
      }
    }
    if(DateTime.now().month+1==4 || DateTime.now().month+1==6 || DateTime.now().month+1==9 || DateTime.now().month==11) {
      end = 30;
    }
    if(DateTime.now().month+1==2) {
      end = 28;
    }
    for(var i=1; i<end;++i) {
      var testDate = DateTime(DateTime.now().year, DateTime.now().month, i);
      if(testDate.weekday==day) {
        return DateTime(DateTime.now().year, DateTime.now().month+1, i);;
      }
    }
    return DateTime.now();
  }

  String get_date_title(String dateTime) {
    if(dateTime=='null' || dateTime.isEmpty) {
      return "No date";
    }
    else {
      DateTime ref = DateTime.parse(dateTime);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime tomorrow = DateTime(now.year, now.month, now.day+1);
      DateTime after_one_week = DateTime(now.year, now.month, now.day+7);
      if(ref.isAtSameMomentAs(today)) {
        return "Today";
      }
      else if(ref.isAtSameMomentAs(tomorrow)) {
        return "Tomorrow";
      }
      else if(ref.isAtSameMomentAs(after_one_week)) {
        return "After 1 week";
      }
      else if(ref.isAtSameMomentAs(get_next_date(DateTime.monday))) {
        return "Next monday";
      }
      else if(ref.isAtSameMomentAs(get_next_date(DateTime.tuesday))) {
        return "Next tuesday";
      }
      else {
        return get_expanded_date_as_string(DateTime.parse(dateTime));
      }
    }
    return dateTime;
  }
}