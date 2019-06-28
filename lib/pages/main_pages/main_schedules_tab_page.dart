import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'package:mobile/blocs/main_tab_blocs/main_tab_blocs.dart';
import 'package:mobile/blocs/request_event.dart';
import 'package:mobile/blocs/response_states.dart';
import 'package:mobile/communication/pojos/PojoClass.dart';
import 'package:mobile/communication/pojos/task/PojoTask.dart';
import 'package:mobile/listItems/TaskHeaderItemWidget.dart';
import 'package:mobile/listItems/TaskItemWidget.dart';
import 'package:mobile/listItems/class_item_widget.dart';
=======
import 'package:hazizz_mobile/blocs/main_tab_blocs/main_tab_blocs.dart';
import 'package:hazizz_mobile/blocs/request_event.dart';
import 'package:hazizz_mobile/blocs/response_states.dart';
import 'package:hazizz_mobile/communication/pojos/PojoClass.dart';
import 'package:hazizz_mobile/communication/pojos/task/PojoTask.dart';
import 'package:hazizz_mobile/listItems/TaskHeaderItemWidget.dart';
import 'package:hazizz_mobile/listItems/TaskItemWidget.dart';
import 'package:hazizz_mobile/listItems/class_item_widget.dart';
>>>>>>> 4c9d004c5a9e9c416ab5b26080cdb3e8a330b7fc


import 'package:sticky_headers/sticky_headers.dart';

class SchedulesTabPage extends StatefulWidget {

  List<PojoClass> classes;

//  List<ClassItemWidget> classWidgets;

  SchedulesTabPage({Key key, @required this.classes}) : super(key: key){

  }


  @override
  _SchedulesTabPage createState() => _SchedulesTabPage();
}

class _SchedulesTabPage extends State<SchedulesTabPage> with TickerProviderStateMixin {
  _SchedulesPage(){}

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new RefreshIndicator(

          onRefresh: () async => print("refresh"),//schedulesBloc.dispatch(FetchData()) //await getData()
          child: ListView.builder(
            itemCount: widget.classes.length,
            itemBuilder: (BuildContext context, int index) {
              return ClassItemWidget(pojoClass: widget.classes[index]);
            }
          )
      ),
    );
  }
}

