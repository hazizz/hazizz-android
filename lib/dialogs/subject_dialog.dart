import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/blocs/group/group_bloc.dart';
import 'package:mobile/blocs/other/request_event.dart';
import 'package:mobile/communication/pojos/PojoSubject.dart';
import 'package:mobile/communication/requests/request_collection.dart';
import 'package:mobile/dialogs/report_dialog.dart';
import 'package:mobile/enums/group_permissions_enum.dart';
import 'package:mobile/widgets/flushbars.dart';
import 'package:mobile/custom/hazizz_localizations.dart';
import 'package:mobile/communication/hazizz_response.dart';
import 'package:mobile/theme/hazizz_theme.dart';
import 'package:mobile/communication/request_sender.dart';
import 'dialog_collection.dart';

class SubjectDialog extends StatefulWidget {

  final PojoSubject subject;

  SubjectDialog({Key key, this.subject}) : super(key: key);

  @override
  _SubjectDialog createState() => new _SubjectDialog();
}

enum PromotableTo{
  MODERATOR,
  USER,
  NONE
}

class _SubjectDialog extends State<SubjectDialog> {

  PojoSubject subject;

  double width = 200;
  double height = 110;

  @override
  void initState() {
    subject = widget.subject;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HazizzDialog(
        header: Container(
          color: Theme.of(context).dialogBackgroundColor,
          child: Stack(
            children: <Widget>[
              Container(
                 height: 52.0,
                  width: 2000,
                  color: Theme.of(context).primaryColor

              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 40.0, left: 0),
                  child: Center(
                    child: AutoSizeText(
                      subject.name,
                      style: TextStyle(fontSize: 36),
                      minFontSize: 20,
                      maxFontSize: 360,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: BlocBuilder(
                  bloc: GroupBlocs().myPermissionBloc,
                  builder: (context, state){


                    List<PopupMenuEntry> entries = [
                      PopupMenuItem(
                        value: "report",
                        child: Text(localize(context, key: "report"),
                          style: TextStyle(color: HazizzTheme.red),
                        ),
                      ),
                    ];
                    if(state is MyPermissionSetState){
                      if(state.permission == GroupPermissionsEnum.MODERATOR || state.permission == GroupPermissionsEnum.OWNER){
                        entries.add(PopupMenuItem(
                          value: "edit",
                          child: Text(localize(context, key: "edit"),),
                        ),
                        );
                      }
                    }
                    if(state is MyPermissionSetState){
                      if(state.permission == GroupPermissionsEnum.MODERATOR || state.permission == GroupPermissionsEnum.OWNER){
                        entries.add(PopupMenuItem(
                          value: "delete",
                          child: Text(localize(context, key: "delete"),
                            style: TextStyle(color: HazizzTheme.red),
                          ),
                        ),
                        );
                      }
                    }



                    return PopupMenuButton(
                      icon: Icon(FontAwesomeIcons.ellipsisV, size: 20,),
                      onSelected: (value) async {
                        if(value == "report"){
                          bool success = await showReportDialog(context, reportType: ReportTypeEnum.SUBJECT, id: widget.subject.id, secondId: GroupBlocs().group.id, name: widget.subject.name);
                          if(success != null && success){
                            showReportSuccessFlushBar(context, what: localize(context, key: "subject"));
                          }
                        }else if(value == "delete"){
                          bool success = await showDeleteSubjectDialog(context, groupId: GroupBlocs().group.id, subject: widget.subject);
                          if(success != null && success){
                            showDeleteWasSuccessfulFlushBar(context, what: "${widget.subject.name} ${localize(context, key: "subject")}");
                            GroupBlocs().groupSubjectsBloc.add(FetchData());
                            Navigator.pop(context);
                          }
                        }else if(value == "edit"){
                          PojoSubject success = await showEditSubjectDialog(context, subject: widget.subject);
                          if(success != null){
                           // showDeleteWasSuccessfulFlushBar(context, what: "${widget.subject.name} ${locText(context, key: "subject")}");
                           // GroupBlocs().groupSubjectsBloc.add(FetchData());
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return entries;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        content: Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: Builder(
              builder: (context){
                if(subject.subscriberOnly){
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("${localize(context, key: "subscribed")}:", style: TextStyle(fontSize: 18),),
                      Transform.scale(scale: 1.3,
                        child: Checkbox(

                          value: subject.subscribed,
                          onChanged: (value) async {
                            setState(() {
                              subject.subscribed = value;
                            });
                            HazizzResponse hazizzResponse = subject.subscribed
                              ? await RequestSender().getResponse(SubscribeToSubject(pSubjectId: subject.id))
                              : await RequestSender().getResponse(UnsubscribeFromSubject(pSubjectId: subject.id));
                            if(hazizzResponse.isSuccessful){
                              if(subject.subscribed){
                                showSubscribedToSubjectFlushBar(context, what: subject.name);
                              }else{
                                showUnsubscribedFromSubjectFlushBar(context, what: subject.name);
                              }
                            }else{
                              setState(() {
                                subject.subscribed = !subject.subscribed;
                              });
                            }
                          },
                          activeColor: Colors.green,
                          checkColor: Colors.white,
                        ),
                      )

                    ],
                  );
                }
                return Container();
              },
            ),
          ),
        ),
        actionButtons: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: FlatButton(
                  child: Center(
                    child: Text(localize(context, key: "close").toUpperCase(),),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ]
        ),
        height: subject.subscriberOnly ? height : height - 54,
        width: width);
  }
}