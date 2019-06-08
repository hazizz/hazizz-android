import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'package:hazizz_mobile/blocs/request_event.dart';
import 'package:hazizz_mobile/blocs/response_states.dart';
import 'package:hazizz_mobile/blocs/tasks_bloc.dart';
import 'package:hazizz_mobile/communication/pojos/task/PojoTask.dart';
import 'package:hazizz_mobile/listItems/TaskHeaderItemWidget.dart';
import 'package:hazizz_mobile/listItems/TaskItemWidget.dart';
=======
import 'package:flutter_hazizz/blocs/request_event.dart';
import 'package:flutter_hazizz/blocs/response_states.dart';
import 'package:flutter_hazizz/blocs/tasks_bloc.dart';
import 'package:flutter_hazizz/communication/pojos/task/PojoTask.dart';
import 'package:flutter_hazizz/listItems/TaskHeaderItemWidget.dart';
import 'package:flutter_hazizz/listItems/TaskItemWidget.dart';
>>>>>>> 697a6e3b071e12017449a7ca76eb8a9feb3f5ba0

import 'package:sticky_headers/sticky_headers.dart';

class TaskPage extends StatefulWidget {
  // This widget is the root of your application.
  TaskPage({Key key}) : super(key: key);

  @override
  _TaskPage createState() => _TaskPage();
}

class _TaskPage extends State<TaskPage> with SingleTickerProviderStateMixin {

  TasksBloc tasksBloc = new TasksBloc();

  //List<PojoTask> task_data = List();

  // lényegében egy onCreate
  @override
  void initState() {
    // getData();
    tasksBloc.dispatch(FetchData());
    //   tasksBloc.fetchMyTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: new RefreshIndicator(
            child: BlocBuilder(
                bloc: tasksBloc,
                //  stream: tasksBloc.subject.stream,
                builder: (_, HState state) {
                  if (state is ResponseDataLoaded) {
                    List<PojoTask> tasks = state.data;
                    return new ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 0 || tasks[index].dueDate
                              .difference(tasks[index - 1].dueDate)
                              .inDays > 0) {
                            return new StickyHeader(
                              header: TaskHeaderItemWidget(
                                  dateTime: tasks[index].dueDate),
                              content: TaskItemWidget(pojoTask: tasks[index],),
                            );
                          } else {
                            return
                              TaskItemWidget(pojoTask: tasks[index],
                              );
                          }
                        }
                    );
                  } else if (state is ResponseEmpty) {
                    return Center(child: Text("Empty"));
                  } else if (state is ResponseWaiting) {
                    //return Center(child: Text("Loading Data"));
                    return Center(child: CircularProgressIndicator(),);
                  }
                  return Center(
                      child: Text("Uchecked State: ${state.toString()}"));
                }

            ),
            onRefresh: () async =>
                tasksBloc.dispatch(FetchData()) //await getData()
        )
    );
  }
}


