import 'package:flutter/material.dart';
import 'package:mobile/blocs/selected_session_bloc.dart';
import 'package:mobile/communication/pojos/PojoSession.dart';
import 'package:mobile/communication/requests/request_collection.dart';
import 'package:mobile/dialogs/dialogs.dart';

import '../hazizz_theme.dart';
import '../request_sender.dart';


class SessionItemWidget extends StatefulWidget  {

  PojoSession session;

  bool selected = false;



  SessionItemWidget({@required this.session}) {
  }

  @override
  _SessionItemWidget createState() => _SessionItemWidget();
}


class _SessionItemWidget extends State<SessionItemWidget>{



  @override
  void initState() {
    // TODO: implement initState



    super.initState();
  }





  @override
  Widget build(BuildContext context) {

    Color backgroundColor = Theme.of(context).backgroundColor;


    const String value_remove = "remove";
    const String value_select = "select";


    return Card(
      // borderOnForeground: true,
       // color: backgroundColor,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 30,
        child: InkWell(
            onTap: () {

            },
            child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(widget.session.username),
                      Container(
                        // color: PojoType.getColor(widget.pojoTask.type),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12)),
                            color: Colors.red
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, top: 4, right: 8, bottom: 6),
                          child: Text(widget.session.status),
                        )
                      ),
                    ],
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Spacer(),
                        Text(widget.session.url),
                        PopupMenuButton(
                          onSelected: (value) async {
                            print("log: value: $value");
                            if(value == value_remove){
                              await RequestSender().getResponse(KretaRemoveSessions(p_session: widget.session.id));
                             // ViewTaskBloc().commentBlocs.commentSectionBloc.dispatch(CommentSectionFetchEvent());
                            }else if(value == value_select){

                              if(widget.session.status != "ACTIVE"){
                                if(await showDialogSessionReauth(context)){
                                  Navigator.pushNamed(context, "/kreta/login/auth", arguments: widget.session);
                                 // Navigator.pushReplacementNamed(context, "routeName", arguments: List());
                                }else{

                                }
                              }else{
                                SelectedSessionBloc().dispatch(SelectedSessionSetEvent(widget.session));
                              }


                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                  value: value_select,
                                  child: GestureDetector(
                                    child: Text("Select",
                                      //   style: TextStyle(color: HazizzTheme.red),
                                    ),
                                  )
                              ),
                              PopupMenuItem(
                                  value: value_remove,
                                  child: GestureDetector(
                                    child: Text("Remove",
                                      style: TextStyle(color: HazizzTheme.red),
                                    ),
                                  )
                              ),

                            ];
                          },
                        )
                      ]
                  )
                ]
            )
        )
    );
  }
}
