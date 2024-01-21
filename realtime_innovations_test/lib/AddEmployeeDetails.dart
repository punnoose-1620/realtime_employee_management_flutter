import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realtime_innovations_test/ColorVals.dart';
import 'package:realtime_innovations_test/CustomFunctions.dart';
import 'package:realtime_innovations_test/Paths.dart';
import 'package:realtime_innovations_test/Values.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEmployeeDetails extends StatefulWidget {
  const AddEmployeeDetails({Key? key}) : super(key: key);

  @override
  State<AddEmployeeDetails> createState() => _AddEmployeeDetailsState();
}

class _AddEmployeeDetailsState extends State<AddEmployeeDetails> {

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  TextEditingController name_controller = TextEditingController();
  String error_text = "";

  DateTime? startDate_selected = DateTime.now();
  DateTime? endDate_selected = DateTime.now();

  TextStyle hintStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: ColorVals().TXT_DULL
  );
  TextStyle entryStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400
  );

  OutlineInputBorder borderTextEntry = OutlineInputBorder(
      borderSide: BorderSide(
          color: ColorVals().BORDER_GREY,
          width: 0.8
      ),
      borderRadius: BorderRadius.circular(5)
  );
  OutlineInputBorder disabledBorderTextEntry = OutlineInputBorder(
      borderSide: BorderSide(
          color: ColorVals().BORDER_GREY,
          width: 1
      ),
      borderRadius: BorderRadius.circular(5)
  );
  OutlineInputBorder enabledBorderTextEntry = OutlineInputBorder(
      borderSide: BorderSide(
          color: ColorVals().BORDER_GREY,
          width: 0.8
      ),
      borderRadius: BorderRadius.circular(5)
  );
  OutlineInputBorder focusedBorderTextEntry = OutlineInputBorder(
      borderSide: BorderSide(
          color: ColorVals().TXT_BLUE,
          width: 1
      ),
      borderRadius: BorderRadius.circular(5)
  );

  bool check_today(String dateType) {
    DateTime ref_date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if(Values().CURRENT_EMP['${dateType}Date']!=null) {
      log("Test parse : "+Values().CURRENT_EMP['${dateType}Date'].toString());
      DateTime temp_date = DateTime.parse(Values().CURRENT_EMP['${dateType}Date']);
      if(temp_date.isAtSameMomentAs(ref_date)) {
        return true;
      }
      return false;
    }
    return false;
  }

  bool check_tomorrow(String dateType) {
    DateTime ref_date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1);
    if(Values().CURRENT_EMP['${dateType}Date']!=null) {
      DateTime temp_date = DateTime.parse(Values().CURRENT_EMP['${dateType}Date']);
      if(temp_date.isAtSameMomentAs(ref_date)) {
        return true;
      }
      return false;
    }
    return false;
  }

  bool check_after_one_week(String dateType) {
    if(dateType=='start') {
      if(startDate_selected!.isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+7))) {
        return true;
      }
      return false;
    }
    else {
      if(endDate_selected!.isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+7))) {
        return true;
      }
      return false;
    }
  }

  void back_clicked() {
    setState(() {
      Values().CURRENT_EMP = {};
      Values().EDIT_EMP_FLAG = false;
    });
    Navigator.popAndPushNamed(context, Paths().EMP_LIST);
  }

  void delete_emp() {
    setState(() {
      for(var item in Values().EMP_LIST) {
        if(item['e_id'].toString()==Values().CURRENT_EMP['e_id'].toString()) {
          item['status'] = 'previous';
        }
      }
    });
    back_clicked();
  }

  void position_selected(String position) {
    setState(() {
      Values().CURRENT_EMP['title'] = position;
    });
  }
  
  void show_positions_popup() async {
    await showDialog(
      context: context,
      builder: (buildContext) {
        return AlertDialog(
          alignment: Alignment.bottomCenter,
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15)
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: get_popup_cards(buildContext),
          ),
        );
      }
    );
  }

  void set_date(String dateType) {
    if(dateType=='start') {}
    else {}
  }

  Future<void> set_emp_cache() async {
    final SharedPreferences prefs = await _prefs;
    List<String> emp_id_list = [];
    for(var item in Values().EMP_LIST) {
      emp_id_list.add(item['e_id'].toString());
      await prefs.setString('name_${item['e_id']}', item['name'].toString());
      await prefs.setString('title_${item['e_id']}', item['title'].toString());
      await prefs.setString('startDate_${item['e_id']}', item['startDate'].toString());
      await prefs.setString('endDate_${item['e_id']}', item['endDate'].toString());
      await prefs.setString('status_${item['e_id']}', item['status'].toString());
    }
    await prefs.setStringList('emp_id_list', emp_id_list);
  }

  DateTime get_this_month_first() {
    DateTime returnVal = DateTime.now();
    String month = "";
    if(returnVal.month<10) {
      month = "0${returnVal.month}";
    }
    else {
      month = "${returnVal.month}";
    }
    returnVal = DateTime.parse("${returnVal.year}-$month-01");
    return returnVal;
  }

  DateTime get_this_year_last() {
    DateTime returnVal = DateTime.now();
    returnVal = DateTime.parse("${returnVal.year}-12-31");
    return returnVal;
  }

  void show_calendar_selection(String dateType) {

    BuildContext? globalBuildContext = null;

    void update_date(String value) {
      setState(() {
        if(value.isEmpty) {
          Values().CURRENT_EMP['${dateType}Date'] = null;
          if(dateType=='start') {
            startDate_selected = null;
          }
          else {
            endDate_selected = null;
          }
        }
        else {
          Values().CURRENT_EMP['${dateType}Date'] = value;
          DateTime datetime = DateTime.parse(value);
          if(dateType=='start') {
            startDate_selected = datetime;
          }
          else {
            endDate_selected = datetime;
          }
          // if(value.toLowerCase()=='today') {
          //   if(dateType=='start') {
          //     startDate_selected = DateTime.now();
          //   }
          //   else {
          //     endDate_selected = DateTime.now();
          //   }
          // }
          // else if(value.toLowerCase()=='tomorrow') {
          //   if(dateType=='start') {
          //     startDate_selected = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1);
          //   }
          //   else {
          //     endDate_selected = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1);
          //   }
          // }
          // else if(value.toLowerCase()=='next monday') {
          //   if(dateType=='start') {
          //     startDate_selected = get_next_date(DateTime.monday);
          //   }
          //   else {
          //     endDate_selected = get_next_date(DateTime.monday);
          //   }
          // }
          // else if(value.toLowerCase()=='next tuesday') {
          //   if(dateType=='start') {
          //     startDate_selected = get_next_date(DateTime.tuesday);
          //   }
          //   else {
          //     endDate_selected = get_next_date(DateTime.tuesday);
          //   }
          // }
          // else if(value.toLowerCase()=='after 1 week') {
          //   if(dateType=='start') {
          //     startDate_selected = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+7);
          //   }
          //   else {
          //     endDate_selected = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+7);
          //   }
          // }
        }
      });
      if(globalBuildContext!=null) {
        Navigator.pop(globalBuildContext!);
        show_calendar_selection(dateType);
      }
    }

    void onDateClicked(DateTime new_date) {
      log("New date selected : ${new_date}");
      setState(() {
        Values().CURRENT_EMP['${dateType}Date'] = new_date.toString().split(" ")[0];
        if(dateType=='start') {
          startDate_selected = new_date;
        }
        else {
          endDate_selected = new_date;
        }
      });
      if(globalBuildContext!=null) {
        Navigator.pop(globalBuildContext!);
        show_calendar_selection(dateType);
      }
    }

    log("Date type : $dateType");

    Widget get_title() {
      if(dateType=="start") {
        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: Values().WIDTH/2.68,
                child: ElevatedButton(
                  onPressed: () {
                    update_date("");
                  },
                  child: Text("No date"),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                        vertical: 15
                    ),
                    backgroundColor: ColorVals().PRIMARY_SKYBLUE.withOpacity(
                      (Values().CURRENT_EMP['${dateType}Date']==null)?
                      1.0:
                      0.1
                    ),
                    foregroundColor: (Values().CURRENT_EMP['${dateType}Date']==null)?
                      ColorVals().TXT_WHITE:
                      ColorVals().PRIMARY_SKYBLUE
                  ,
                  ),
                ),
              ),

              SizedBox(width: 15,),

              SizedBox(
                width: Values().WIDTH/2.68,
                child: ElevatedButton(
                  onPressed: () {
                    update_date(DateTime.now().toString().split(" ")[0]);
                  },
                  child: Text("Today"),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                        vertical: 15
                    ),
                    backgroundColor: ColorVals().PRIMARY_SKYBLUE.withOpacity(check_today(dateType)?1.0:0.1),
                    foregroundColor: check_today(dateType)?ColorVals().TXT_WHITE:ColorVals().PRIMARY_SKYBLUE
                    ,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      else {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: Values().WIDTH/2.68,
                    child: ElevatedButton(
                      onPressed: () {
                        update_date("");
                      },
                      child: Text("No date"),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                            vertical: 15
                        ),
                        backgroundColor: ColorVals().PRIMARY_SKYBLUE.withOpacity(
                            (Values().CURRENT_EMP['${dateType}Date']==null)?
                            1.0:
                            0.1
                        ),
                        foregroundColor: (Values().CURRENT_EMP['${dateType}Date']==null)?
                        ColorVals().TXT_WHITE:
                        ColorVals().PRIMARY_SKYBLUE
                        ,
                      ),
                    ),
                  ),

                  SizedBox(width: 15,),

                  SizedBox(
                    width: Values().WIDTH/2.68,
                    child: ElevatedButton(
                      onPressed: () {
                        update_date(CustomFunctions().get_next_date(DateTime.monday).toString().split(" ")[0]);
                      },
                      child: Text("Next Monday"),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                            vertical: 15
                        ),
                        backgroundColor: ColorVals().PRIMARY_SKYBLUE.withOpacity(
                            (Values().CURRENT_EMP['${dateType}Date'].toString()==CustomFunctions().get_next_date(DateTime.monday).toString().split(" ")[0])?
                            1.0:
                            0.1
                        ),
                        foregroundColor: (Values().CURRENT_EMP['${dateType}Date'].toString()==CustomFunctions().get_next_date(DateTime.monday).toString().split(" ")[0])?
                        ColorVals().TXT_WHITE:
                        ColorVals().PRIMARY_SKYBLUE
                        ,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 10,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: Values().WIDTH/2.68,
                    child: ElevatedButton(
                      onPressed: () {
                        update_date(CustomFunctions().get_next_date(DateTime.tuesday).toString().split(" ")[0]);
                      },
                      child: Text("Next Tuesday"),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                            vertical: 15
                        ),
                        backgroundColor: ColorVals().PRIMARY_SKYBLUE.withOpacity(
                            (Values().CURRENT_EMP['${dateType}Date'].toString()==CustomFunctions().get_next_date(DateTime.tuesday).toString().split(" ")[0])?
                            1.0:
                            0.1
                        ),
                        foregroundColor: (Values().CURRENT_EMP['${dateType}Date'].toString()==CustomFunctions().get_next_date(DateTime.tuesday).toString().split(" ")[0])?
                        ColorVals().TXT_WHITE:
                        ColorVals().PRIMARY_SKYBLUE
                        ,
                      ),
                    ),
                  ),

                  SizedBox(width: 15,),

                  SizedBox(
                    width: Values().WIDTH/2.68,
                    child: ElevatedButton(
                      onPressed: () {
                        update_date(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+7).toString().split(" ")[0]);
                      },
                      child: Text("After 1 week"),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                            vertical: 15
                        ),
                        backgroundColor: ColorVals().PRIMARY_SKYBLUE.withOpacity(check_after_one_week(dateType)?1.0:0.1),
                        foregroundColor: check_after_one_week(dateType)?ColorVals().TXT_WHITE:ColorVals().PRIMARY_SKYBLUE
                        ,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }
    }

    Widget get_bottom_bar() {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: ColorVals().BORDER_GREY.shade300,
              width: 1
            )
          )
        ),
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 25
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Image.asset(Paths().ASSETS_FOLDER+"today_icon.png"),
                ),
                SizedBox(width: 10,),
                Text(
                  CustomFunctions().get_expanded_date_as_string(dateType=='start'?startDate_selected:endDate_selected),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColorVals().TXT_BLACK
                  ),
                )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      Values().CURRENT_EMP['${dateType}Date'] = null;
                    });
                    if(globalBuildContext!=null) {
                      Navigator.pop(globalBuildContext!);
                    }
                  },
                  child: Text("Cancel"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorVals().PRIMARY_SKYBLUE.withOpacity(0.13),
                      foregroundColor: ColorVals().TXT_BLUE,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      )
                  ),
                ),

                SizedBox(width: 10,),

                ElevatedButton(
                  onPressed: () {
                    if(globalBuildContext!=null) {
                      Navigator.pop(globalBuildContext!);
                    }
                  },
                  child: Text("Save"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorVals().TXT_BLUE,
                      foregroundColor: ColorVals().TXT_WHITE,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      )
                  ),
                )
              ],
            )
          ],
        ),
      );
    }

    DateTime get_initialDate() {
      if(dateType=='start') {
        if(startDate_selected!=null) {
          return startDate_selected!;
        }
        return DateTime.now();
      }
      else {
        if(endDate_selected!=null) {
          return endDate_selected!;
        }
        return DateTime.now();
      }
    }

    showDialog(
      context: context,
      builder: (buildContext) {
        globalBuildContext = buildContext;
        return AlertDialog(
          alignment: Alignment.center,
          backgroundColor: ColorVals().TXT_WHITE,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: 20
          ),
          contentPadding: EdgeInsets.zero,
          title: get_title(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30,),
              Container(
                // color: Colors.green,
                width: Values().WIDTH/1.5,
                height: Values().WIDTH/1.5,
                child: CalendarDatePicker(
                    initialDate: get_initialDate(),
                    firstDate: get_this_month_first(),
                    lastDate: get_this_year_last(),
                    currentDate: dateType=='start'?startDate_selected:endDate_selected,
                    initialCalendarMode: DatePickerMode.day,
                    onDateChanged: onDateClicked
                ),
              ),

              SizedBox(height: 30,),

              get_bottom_bar(),
            ],
          ),
        );
      }
    );
  }

  bool validate() {
    if(name_controller.text.trim().isEmpty) {
      setState(() {
        error_text = "Name cannot be empty";
      });
      return false;
    }
    else if(Values().CURRENT_EMP['title']==null || Values().CURRENT_EMP['title'].toString().isEmpty) {
      setState(() {
        error_text = "Please select appropriate title";
      });
      return false;
    }
    else if(Values().CURRENT_EMP['startDate']==null || Values().CURRENT_EMP['startDate'].toString().isEmpty) {
      setState(() {
        error_text = "Please select appropriate starting date";
      });
      return false;
    }
    return true;
  }

  void submit() async {
    if(validate()) {
      if(Values().EDIT_EMP_FLAG) {
        log("Edit Emp Submit");
        for(var item in Values().EMP_LIST) {
          if(item['e_id'].toString()==Values().CURRENT_EMP['e_id'].toString()) {
            setState(() {
              item['name'] = Values().CURRENT_EMP['name'].toString();
              item['title'] = Values().CURRENT_EMP['title'].toString();
              item['startDate'] = Values().CURRENT_EMP['startDate'].toString().split(" ")[0];
              item['endDate'] = Values().CURRENT_EMP['endDate'].toString().split(" ")[0];
            });
          }
        }
      }
      else {
        log("Add Emp Submit");
        Values().CURRENT_EMP['e_id'] = Values().EMP_LIST.length.toString();
        Values().CURRENT_EMP['status'] = "current";
        setState(() {
          Values().EMP_LIST.add(Values().CURRENT_EMP);
        });
      }
      await set_emp_cache();
      back_clicked();
    }
  }

  AppBar? get_appBar() {
    return AppBar(
      backgroundColor: ColorVals().PRIMARY_SKYBLUE,
      title: Text(
        "${Values().EDIT_EMP_FLAG?'Edit':'Add'} Employee Details",
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorVals().TXT_WHITE
        ),
      ),
      actions: (Values().EDIT_EMP_FLAG && Values().CURRENT_EMP['status']=='current')?[
        ElevatedButton(
          onPressed: () {},
          child: Icon(CupertinoIcons.delete),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: ColorVals().PRIMARY_SKYBLUE,
            foregroundColor: ColorVals().TXT_WHITE
          ),
        )
      ]:[],
    );
  }

  List<Widget> get_popup_cards(BuildContext buildContext) {
    List<Widget> cards = [];
    for(var item in Values().POSITIONS) {
      cards.add(Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 1),
        decoration: BoxDecoration(
            color: ColorVals().PRIMARY_GREY,
            borderRadius: (item==Values().POSITIONS.first)?
            BorderRadius.vertical(top: Radius.circular(25)):
            BorderRadius.zero
        ),
        child: SizedBox(
          width: Values().WIDTH,
          child: ElevatedButton(
            child: Text(item),
            onPressed: () {
              position_selected(item);
              Navigator.pop(buildContext);
            },
            style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: ColorVals().TXT_WHITE,
                foregroundColor: ColorVals().TXT_BLACK,
                padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: (item==Values().POSITIONS.first)?
                    BorderRadius.vertical(top: Radius.circular(25)):
                    BorderRadius.zero
                )
            ),
          ),
        ),
      ));
    }
    return cards;
  }

  Widget get_body() {
    return SingleChildScrollView(
      child: Container(
        height: Values().HEIGHT,
        color: ColorVals().TXT_WHITE,
        padding: EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 20
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: name_controller,
              onChanged: (name) {
                setState(() {
                  Values().CURRENT_EMP['name'] = name;
                });
              },
              style: entryStyle,
              decoration: InputDecoration(
                border: borderTextEntry,
                hintText: "Employee name",
                focusedBorder: focusedBorderTextEntry,
                enabledBorder: enabledBorderTextEntry,
                disabledBorder: disabledBorderTextEntry,
                hintStyle: hintStyle,
                prefixIcon: Icon(
                  CupertinoIcons.person,
                  color: ColorVals().TXT_BLUE,
                )
              ),
            ),
            SizedBox(height: 30,),
            
            SizedBox(
              width: Values().WIDTH,
              child: ElevatedButton(
                onPressed: show_positions_popup,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Image.asset(Paths().ASSETS_FOLDER+"briefcase_icon.png"),
                        ),
                        SizedBox(width: 15,),

                        Text(
                          (Values().CURRENT_EMP['title']!=null)?Values().CURRENT_EMP['title'].toString():"Select role",
                          style: (Values().CURRENT_EMP['title']!=null)?entryStyle:hintStyle
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 45,
                      color: ColorVals().TXT_BLUE,
                    )
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: ColorVals().TXT_WHITE,
                  foregroundColor: ColorVals().TXT_BLACK,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: ColorVals().BORDER_GREY,
                      width: 0.8
                    ),
                    borderRadius: BorderRadius.circular(5)
                  ),
                  padding: EdgeInsets.fromLTRB(15, 5, 8, 5)
                ),
              ),
            ),
            SizedBox(height: 30,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: Values().WIDTH/2.6,
                  child: ElevatedButton(
                    onPressed: () {
                      show_calendar_selection('start');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Image.asset(Paths().ASSETS_FOLDER+"today_icon.png"),
                        ),
                        SizedBox(width: 15,),

                        SizedBox(
                          width: Values().WIDTH-316,
                          child: Text(
                              CustomFunctions().get_date_title(Values().CURRENT_EMP['startDate'].toString()),
                              style: (Values().CURRENT_EMP['startDate']!=null)?entryStyle:hintStyle
                          ),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: ColorVals().TXT_WHITE,
                        foregroundColor: ColorVals().TXT_BLACK,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: ColorVals().BORDER_GREY,
                                width: 0.8
                            ),
                            borderRadius: BorderRadius.circular(5)
                        ),
                        padding: EdgeInsets.fromLTRB(15, 15, 8, 15)
                    ),
                  ),
                ),

                Icon(
                  CupertinoIcons.arrow_right,
                  color: ColorVals().TXT_BLUE,
                ),

                SizedBox(
                  width: Values().WIDTH/2.6,
                  child: ElevatedButton(
                    onPressed: () {
                      show_calendar_selection('end');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Image.asset(Paths().ASSETS_FOLDER+"today_icon.png"),
                        ),
                        SizedBox(width: 15,),

                        SizedBox(
                          width: Values().WIDTH-316,
                          child: Text(
                              CustomFunctions().get_date_title(Values().CURRENT_EMP['endDate'].toString()),
                              style: (Values().CURRENT_EMP['endDate']!=null)?entryStyle:hintStyle
                          ),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: ColorVals().TXT_WHITE,
                        foregroundColor: ColorVals().TXT_BLACK,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: ColorVals().BORDER_GREY,
                                width: 0.8
                            ),
                            borderRadius: BorderRadius.circular(5)
                        ),
                        padding: EdgeInsets.fromLTRB(15, 15, 8, 15)
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50,),
          ],
        )
      ),
    );
  }

  Widget get_bottomButtons() {
    return Container(
      width: Values().WIDTH,
      decoration: BoxDecoration(
        color: ColorVals().TXT_WHITE,
        border: Border(
          top: BorderSide(
            color: ColorVals().BORDER_GREY.withOpacity(0.7),
            width: 0.5
          )
        )
      ),
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 15
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          error_text.isNotEmpty?
            SizedBox(
              width: Values().WIDTH/2,
              child: Text(
                error_text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorVals().BACKGROUND_DELETE_RED
                )
              )
            ):
            SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: back_clicked,
                child: Text("Cancel"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: ColorVals().PRIMARY_SKYBLUE.withOpacity(0.13),
                    foregroundColor: ColorVals().TXT_BLUE,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    )
                ),
              ),

              SizedBox(width: 10,),

              ElevatedButton(
                onPressed: submit,
                child: Text("Save"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: error_text.isEmpty?ColorVals().TXT_BLUE:ColorVals().BORDER_GREY,
                    foregroundColor: ColorVals().TXT_WHITE,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    )
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    if(Values().EDIT_EMP_FLAG) {
      name_controller.text = Values().CURRENT_EMP['name'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: get_appBar(),
        body: get_body(),
        floatingActionButton: get_bottomButtons(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
      onWillPop: () async {
        back_clicked();
        return false;
      }
    );
  }
}
