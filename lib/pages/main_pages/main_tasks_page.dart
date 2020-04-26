import 'dart:math';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/blocs/main_tab/main_tab_blocs.dart';
import 'package:mobile/blocs/other/response_states.dart';
import 'package:mobile/blocs/tasks/tasks_bloc.dart';
import 'package:mobile/communication/custom_response_errors.dart';
import 'package:mobile/communication/pojos/task/PojoTask.dart';
import 'package:mobile/custom/formats.dart';
import 'package:mobile/custom/hazizz_logger.dart';
import 'package:mobile/enums/task_complete_state_enum.dart';
import 'package:mobile/enums/task_expired_state_enum.dart';
import 'package:mobile/widgets/ad_widget.dart';
import 'package:mobile/widgets/listItems/task_header_item_widget.dart';
import 'package:mobile/widgets/listItems/task_item_widget.dart';
import 'package:mobile/widgets/scroll_space_widget.dart';
import 'package:mobile/widgets/tab_widget.dart';
import 'package:mobile/extension_methods/duration_extension.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:mobile/custom/hazizz_localizations.dart';

class TasksPage extends TabWidget {
  TasksPage({Key key}) : super(key: key){
    tabName = "TasksTab";
  }

  getUIName(BuildContext context){
    return locText(context, key: "tasks").toUpperCase();
  }

  @override
  _TasksPage createState() => _TasksPage();
}



class _TasksPage extends State<TasksPage>
    with TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin{

  TaskCompleteState currentCompletedTaskState;

  TaskExpiredState currentExpiredTaskState;


 // final ItemScrollController itemScrollController = ItemScrollController();
 // final ItemPositionsListener itemPositionListener = ItemPositionsListener.create();

  final ScrollController scrollController = ScrollController();

  bool _scrollToTopVisible = false;

  void scrollToTop(){
    WidgetsBinding.instance.addPostFrameCallback((_) {

      scrollController.animateTo(0, duration: 400.milliseconds, curve: Curves.ease);

      /*
      itemScrollController.scrollTo(
        duration: Duration(milliseconds: 400),
        index: 0,
      );
      */
      setState(() {
        _scrollToTopVisible = false;
      });
    });

  }
  /*
  void scrollTo2({int index}){
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(index != null) currentEventIndex = index;
      print("scrolling: $currentEventIndex");
      itemScrollController?.scrollTo(
          index: currentEventIndex,
          duration: Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic
      );
      print("scrolling: $currentEventIndex yes");

    });
  }
  */

  @override
  void initState() {
    scrollController.addListener((){
      if(scrollController.offset > MediaQuery.of(context).size.height * 1.2){
        setState(() {
          _scrollToTopVisible = true;
        });
      }else{
        setState(() {
          _scrollToTopVisible = false;
        });
      }
    });

    /*
    itemPositionListener.itemPositions.addListener((){
      List<ItemPosition> positions =  itemPositionListener.itemPositions.value.toList();
     /* for(ItemPosition p in positions){
        HazizzLogger.printLog("yad79: " + p.index.toString());
        if(p.index > 12){
          setState(() {
            _scrollToTopVisible = true;
          });
          break;
        }
      }*/
      HazizzLogger.printLog("yad79: " + positions[positions.length-1].index.toString());
      if(positions[positions.length-1].index >= 4){
        setState(() {
          _scrollToTopVisible = true;
        });
      }else{
        setState(() {
          _scrollToTopVisible = false;
        });
      }

    });
    */
    currentCompletedTaskState = MainTabBlocs().tasksBloc.currentTaskCompleteState;
    currentExpiredTaskState = MainTabBlocs().tasksBloc.currentTaskExpiredState;

    super.initState();
  }


  void applyFilters(){
    MainTabBlocs().tasksBloc.currentTaskCompleteState = currentCompletedTaskState;
    MainTabBlocs().tasksBloc.currentTaskExpiredState = currentExpiredTaskState;
  }

  @override
  void dispose() {
    super.dispose();
  }



  Map<DateTime, List<PojoTask>> map;


  Widget onLoaded(Map<DateTime, List<PojoTask>> m){

    map = m;

    HazizzLogger.printLog("REBUILD, BIIP BOOp");

    return new Column(
      children: <Widget>[

        Card(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  //  Text("Feladatok:"),

                  DropdownButton(
                    value: currentCompletedTaskState,
                    onChanged: (value){
                      setState(() {
                        currentCompletedTaskState = value;
                      });
                    },
                    items: [
                      DropdownMenuItem(child: Text(locText(context, key: "complete")), value: TaskCompleteState.COMPLETED, ),
                      DropdownMenuItem(child: Text(locText(context, key: "incomplete")), value: TaskCompleteState.UNCOMPLETED,),
                      DropdownMenuItem(child: Text(locText(context, key: "both")), value: TaskCompleteState.BOTH, ),

                    ],
                  ),
                  // Text("Feladatok:"),

                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: DropdownButton(
                      value: currentExpiredTaskState,
                      onChanged: (value){
                        setState(() {
                          currentExpiredTaskState = value;
                        });
                      },
                      items: [
                        DropdownMenuItem(child: Text(locText(context, key: "expired")), value: TaskExpiredState.EXPIRED,),
                        DropdownMenuItem(child: Text(locText(context, key: "active")), value: TaskExpiredState.UNEXPIRED,)
                      ],
                    ),
                  ),
                  Spacer(),

                  FlatButton(child: Text(locText(context, key: "apply").toUpperCase(), style: TextStyle(fontSize: 13),),
                    onPressed: (){

                      applyFilters();

                      MainTabBlocs().tasksBloc.add(TasksFetchEvent());
                    },
                  )
                ],
              ),
            )
        ),

        Expanded(
          child: Builder(builder: (context){
            if(map.keys == null || map.keys.isEmpty){
              return Center(child: Text(locText(context, key: "no_tasks")),);


            }else{

              int itemCount = map.keys.length+1;
              return ListView.separated(
                addAutomaticKeepAlives: true,
                controller: scrollController,
                //itemScrollController: itemScrollController,
               // itemPositionsListener: itemPositionListener,
                itemCount: itemCount,
                  separatorBuilder: (context, index ){
                    return showAd(context, show: (itemCount<3 && index == itemCount-1) || (index!=0 && index%3==0), showHeader: true);
                  },
                  itemBuilder: (BuildContext context, int index) {

                    if(index == 0){
                      return Center(child: Text(dateTimeToLastUpdatedFormat(context, MainTabBlocs().tasksBloc.lastUpdated)));
                    }

                    List<GlobalKey<AnimatedListState>> listKeyList = new List(map.keys.length);
                    for(int i = 0; i < listKeyList.length; i++){
                      listKeyList[i] =  GlobalKey();
                    }

                    DateTime key = map.keys.elementAt(index-1);
                    HazizzLogger.printLog("new key: ${key.toString()}");

                    Widget s = StickyHeader(
                      header: TaskHeaderItemWidget(key: Key(Random().nextInt(2000000).toString()), dateTime: key),
                      content: Builder(
                        builder: (context) {
                          return Column(
                            children: <Widget>[
                              AnimatedList(
                                key: listKeyList[index-1],
                                //   key: Key(Random().nextInt(2000000).toString()),
                                shrinkWrap: true,
                                initialItemCount: map[key].length,

                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index2, animation) => buildItem(context, index2, animation, map[key][index2], (){

                                  HazizzLogger.printLog("bro: me: ${currentCompletedTaskState}");

                                  if(currentCompletedTaskState != TaskCompleteState.BOTH){
                                    HazizzLogger.printLog("bro: im trigered");

                                    var removedItem = map[key][index2];

                                    listKeyList[index-1].currentState.removeItem(index2, (context2, animation2){
                                      animation2.addStatusListener((AnimationStatus animationStatus){
                                        HazizzLogger.printLog("oof22: anim: ${animationStatus.toString()}");
                                        if(animationStatus == AnimationStatus.dismissed){
                                          HazizzLogger.printLog("oof: ${map[key]}");
                                          MainTabBlocs().tasksBloc.add(TasksRemoveItemEvent( mapKey: key, index: index2));
                                        }
                                      });
                                      return buildItem(context2, index2, animation2, removedItem, (){});
                                    },
                                        duration:  Duration(milliseconds: 500)
                                    );
                                  }
                                }),
                              ),
                            ],
                          );
                        }
                      ),
                    );

                    if(index == itemCount-1 /*|| true*/){
                      return addScrollSpace(s);
                    }
                    return s;
                  }
              );
            }
          }),
        ),

      ],
    );
  }

  Widget buildItem(BuildContext context, int index, Animation animation, PojoTask pojoTask, Function onCompletedChanged){
    Animation<Offset> a = Tween<Offset>(begin: Offset(-1, 0.0), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          0.1,
          1.0,
          curve: Curves.easeOutSine,
         ),
      )
    );
    return SlideTransition(
      position: a,
      child: TaskItemWidget(originalPojoTask: pojoTask, onCompletedChanged: onCompletedChanged, key: Key(pojoTask.toJson().toString()),)
    );
  }

  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      body: Column(
        children: <Widget>[
          BlocBuilder(
            bloc: MainTabBlocs().tasksBloc,
            builder: (context, state){
              if(state is TasksWaitingState || state is TasksLoadedCacheState){
                return LinearProgressIndicator(
                  value: null,
                );
              }
              return Container();
            },
          ),
          Expanded(
            child: new RefreshIndicator(
              child: Stack(
                children: <Widget>[
                  ListView(),
                  BlocBuilder(
                      bloc: MainTabBlocs().tasksBloc,
                      //  stream: tasksBloc.subject.stream,
                      builder: (_, TasksState state) {
                        if (state is TasksLoadedState) {
                          Map<DateTime, List<PojoTask>> tasks = state.tasks;

                          HazizzLogger.printLog("onLoaded asdasd");
                          return onLoaded(tasks);

                        }if (state is TasksLoadedCacheState) {
                          Map<DateTime, List<PojoTask>> tasks = state.tasks;

                          return onLoaded(tasks);

                        } else if (state is ResponseEmpty) {
                          return Column(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 50.0),
                                    child: Text(locText(context, key: "no_tasks_yet")),
                                  ),
                                )
                              ]
                          );
                        } else if (state is TasksWaitingState) {
                          //return Center(child: Text("Loading Data"));
                          return Center(child: CircularProgressIndicator(),);
                        }else if (state is TasksErrorState) {
                          //return Center(child: Text("Loading Data"));
                          if(state.hazizzResponse.dioError == noConnectionError){

                          }else{
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Flushbar(
                                icon: Icon(FontAwesomeIcons.exclamation, color: Colors.red,),

                                message: "${locText(context, key: "tasks")}: ${locText(context, key: "info_something_went_wrong")}",
                                duration: Duration(seconds: 3),
                              );
                            });
                          }
                          if(MainTabBlocs().tasksBloc.tasks!= null){
                            return onLoaded(MainTabBlocs().tasksBloc.tasks);
                          }
                          return Center(
                              child: Text(locText(context, key: "info_something_went_wrong")));
                        }
                        return Center(
                            child: Text(locText(context, key: "info_something_went_wrong")));
                      }
                  ),
                ],
              ),
              onRefresh: () async{
                applyFilters();
                MainTabBlocs().tasksBloc.add(TasksFetchEvent()); //await getData()
                HazizzLogger.printLog("log: refreshing tasks");
                return;
              }
            ),
          ),
        ],

      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedOpacity(
            opacity: _scrollToTopVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: FloatingActionButton(
              heroTag: "2",
              onPressed: scrollToTop,
              child: Icon(FontAwesomeIcons.longArrowAltUp),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            heroTag: "1",
            onPressed: (){
              Navigator.pushNamed(context, "/createTask");
            },
            child: Icon(FontAwesomeIcons.plus),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}