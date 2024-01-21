import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:realtime_innovations_test/ColorVals.dart';
import 'package:realtime_innovations_test/CustomFunctions.dart';
import 'package:realtime_innovations_test/Paths.dart';
import 'package:realtime_innovations_test/Values.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeList extends StatefulWidget {
  const EmployeeList({Key? key}) : super(key: key);

  @override
  State<EmployeeList> createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool back_clicked = false;
  bool loading = true;

  Future<void> get_emp_cache() async {
    final SharedPreferences prefs = await _prefs;
    List<dynamic> emp_list = [];
    List<String>? emp_ids = await prefs.getStringList("emp_id_list");
    if(emp_ids!=null) {
      for(var e_id in emp_ids) {
        var employee = {
          'e_id' : e_id.toString(),
        };
        String? name = await prefs.getString('name_$e_id');
        String? title = await prefs.getString('title_$e_id');
        String? startDate = await prefs.getString('startDate_$e_id');
        String? endDate = await prefs.getString('endDate_$e_id');
        String? status = await prefs.getString('status_$e_id');
        employee['name'] = name.toString();
        employee['title'] = title.toString();
        employee['startDate'] = startDate.toString();
        employee['endDate'] = endDate.toString();
        employee['status'] = status.toString();
        emp_list.add(employee);
      }
      setState(() {
        Values().EMP_LIST = emp_list;
      });
    }
    setState(() {
      loading = false;
    });
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

  Future<bool> back_pressed() async {
    if(back_clicked) {
      return true;
    }
    setState(() {
      back_clicked = true;
    });
    Fluttertoast.showToast(msg: "Press back again to exit");
    return false;
  }

  void delete_employee(String e_id) async {
    log("Delete Employee : $e_id");
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('status_$e_id', "previous");
    for(var item in Values().EMP_LIST) {
      if(item['e_id'].toString()==e_id) {
        setState(() {
          item['endDate'] = DateTime.now().toString().split(" ")[0];
          item['status'] = "previous";
        });
      }
    }
  }

  void add_button_clicked() {
    Navigator.popAndPushNamed(context, Paths().ADD_EMP);
  }

  void edit_employee_clicked(dynamic item) {
    setState(() {
      Values().CURRENT_EMP = item;
      Values().EDIT_EMP_FLAG = true;
    });
    Navigator.popAndPushNamed(context, Paths().ADD_EMP);
  }

  AppBar? get_appBar() {
    return AppBar(
      backgroundColor: ColorVals().PRIMARY_SKYBLUE,
      title: Text(
        "Employee List",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: ColorVals().TXT_WHITE
        ),
      ),
    );
  }

  Widget get_empCard(dynamic item, bool first) {
    if(item['status']!=null && item['status']=="current") {
      return Container(
        child: Slidable(
          child: ElevatedButton(
            onPressed: () {
              edit_employee_clicked(item);
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
              decoration: BoxDecoration(
                color: ColorVals().TXT_WHITE,
                border: first?null:Border(
                    top: BorderSide(
                        color: ColorVals().BORDER_GREY.shade300
                    )
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: Values().WIDTH,
                    child: Text(
                      item['name'].toString(),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ColorVals().TXT_BLACK
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),

                  SizedBox(
                    width: Values().WIDTH,
                    child: Text(
                      item['title'].toString(),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: ColorVals().TXT_DULL
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),

                  SizedBox(
                    width: Values().WIDTH,
                    child: Text(
                      "From ${CustomFunctions().get_date_title(item['startDate'].toString())}",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: ColorVals().TXT_DULL
                      ),
                    ),
                  ),
                ],
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: EdgeInsets.zero,
              backgroundColor: ColorVals().TXT_WHITE,
              foregroundColor: ColorVals().TXT_BLACK
            ),
          ),
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (slide_context) {
                  delete_employee(item['e_id'].toString());
                },
                backgroundColor: ColorVals().BACKGROUND_DELETE_RED,
                icon: CupertinoIcons.delete,
              )
            ]
          ),
        ),
      );
    }
    else {
      return ElevatedButton(
        onPressed: () {
          edit_employee_clicked(item);
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: ColorVals().TXT_WHITE,
            border: first?null:Border(
                top: BorderSide(
                    color: ColorVals().BORDER_GREY.shade300
                )
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: Values().WIDTH,
                child: Text(
                  item['name'].toString(),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorVals().TXT_BLACK
                  ),
                ),
              ),
              SizedBox(height: 15,),

              SizedBox(
                width: Values().WIDTH,
                child: Text(
                  item['title'].toString(),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ColorVals().TXT_DULL
                  ),
                ),
              ),
              SizedBox(height: 15,),

              SizedBox(
                width: Values().WIDTH,
                child: Text(
                  "${CustomFunctions().get_date_title(item['startDate'].toString())} - ${CustomFunctions().get_date_title(item['endDate'].toString())}",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ColorVals().TXT_DULL
                  ),
                ),
              ),
            ],
          ),
        ),
        style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.zero,
            backgroundColor: ColorVals().TXT_WHITE,
            foregroundColor: ColorVals().TXT_BLACK
        ),
      );
    }
  }

  List<Widget> get_empList() {
    List<Widget> cards = [];
    List<dynamic> current = [];
    List<dynamic> previous = [];
    for(var emp in Values().EMP_LIST) {
      if(emp['status']!=null && emp['status'].toString()=="current") {
        current.add(emp);
      }
      else if(emp['status']!=null && emp['status'].toString()=="previous") {
        previous.add(emp);
      }
    }
    //Add Current Cards
    if(current.isNotEmpty) {
      cards.add(Container(
        width: Values().WIDTH,
        padding: EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          "Current Employees",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColorVals().TXT_BLUE
          ),
        ),
      ));
      for(var emp in current) {
        cards.add(get_empCard(emp, emp==current.first));
      }
    }
    //Add Previous Cards
    if(previous.isNotEmpty) {
      cards.add(Container(
        width: Values().WIDTH,
        padding: EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          "Previous Employees",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColorVals().TXT_BLUE
          ),
        ),
      ));
      for(var emp in previous) {
        cards.add(get_empCard(emp, emp==previous.first));
      }
    }
    if(current.isNotEmpty) {
      cards.add(Container(
        width: Values().WIDTH,
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15
        ),
        child: Text(
          "Swipe left to delete",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: ColorVals().TXT_DULL
          ),
        ),
      ));
    }
    return cards;
  }

  Widget get_body() {
    if(loading) {
      return Container(
        height: Values().HEIGHT,
        width: Values().WIDTH,
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
        child: SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            color: ColorVals().PRIMARY_SKYBLUE,
          )
        ),
      );
    }
    else {
      if(Values().EMP_LIST.isNotEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: get_empList(),
        );
      }
      //Employees Empty Empty Case return
      return Container(
        height: Values().HEIGHT,
        width: Values().WIDTH,
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: Values().WIDTH/1.6,
              height: Values().WIDTH/1.6,
              child: Image.asset(Paths().ASSETS_FOLDER+"no_employees.png"),
            ),
            SizedBox(
                width: Values().WIDTH,
                child: Text(
                  "No Employee Records Found",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500
                  ),
                )
            ),
            SizedBox(height: 100,)
          ],
        ),
      );
    }
  }

  Widget? get_addButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
      child: SizedBox(
        height: 50,
        width: 50,
        child: ElevatedButton(
          onPressed: add_button_clicked,
          child: Icon(
            Icons.add,
            size: 30,
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: ColorVals().PRIMARY_SKYBLUE,
            foregroundColor: ColorVals().TXT_WHITE
          ),
        ),
      )
    );
  }

  @override
  void initState() {
    get_emp_cache();
    log("Emp List : ${Values().EMP_LIST}");
  }

  @override
  void dispose() {
    super.dispose();
    set_emp_cache();
  }

  @override
  Widget build(BuildContext context) {
    Values().HEIGHT = MediaQuery.of(context).size.height;
    Values().WIDTH = MediaQuery.of(context).size.width;
    log("Emp List : ${Values().EMP_LIST}");
    return WillPopScope(
      child: Scaffold(
        appBar: get_appBar(),
        backgroundColor: ColorVals().BORDER_GREY.shade100,
        body: SingleChildScrollView(
          child: get_body(),
        ),
        floatingActionButton: get_addButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      ),
      onWillPop: back_pressed
    );
  }
}
