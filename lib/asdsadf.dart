/*
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mobile/communication/pojos/PojoTag.dart';
import 'package:mobile/communication/pojos/task/PojoTask.dart';
import 'package:mobile/communication/requests/request_collection.dart';
import 'package:mobile/custom/hazizz_logger.dart';
import 'package:mobile/theme/hazizz_theme.dart';
import 'package:mobile/communication/request_sender.dart';

class TheraTaskItemWidget extends StatelessWidget  {

	final PojoTask task;

	PojoTag mainTag;
	Color mainColor = Colors.grey;

	List<PojoTag> tags = [];

	TheraTaskItemWidget(this.task, {Key key}) : super(key: key) {
		bool doBreak = false;
		if(task.tags != null){
			tags.addAll(task.tags);

			for(PojoTag t in task.tags) {
				if(!doBreak){
					for(PojoTag defT in PojoTag.defaultTags) {
						if(defT.name == t.name) {
							tags.remove(t);
							mainTag = t;
							mainColor = t.getColor();
							doBreak = true;
							break;getCorrectTaskItemWidget
						}
					}
				}else{
					break;
				}
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		return  Card(
				margin: EdgeInsets.only(left: 7, right: 7, top: 3, bottom: 3),
				clipBehavior: Clip.antiAliasWithSaveLayer,
				elevation: 5,
				child: InkWell(
					onTap: () async {
						await Navigator.pushNamed(context, "/viewTask", arguments: task.copy());
					},
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: <Widget>[
							Row(
								mainAxisAlignment: MainAxisAlignment.start,
								crossAxisAlignment: CrossAxisAlignment.start,

								children: <Widget>[
									Container(
										width: MediaQuery.of(context).size.width-60,
										child: Wrap(
											alignment: WrapAlignment.start,
											runSpacing: 1.4 ,
											crossAxisAlignment: WrapCrossAlignment.center,
											spacing: 2,
											children: [
												Container(
													decoration: BoxDecoration(
															borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)),
															color: mainColor
													),
													child: Padding(
														padding: const EdgeInsets.only(
																left: 3, top: 0, right: 6, bottom: 0),
														child: Text(mainTag?.getDisplayName(context) ?? "",
															style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),),
													)
												),
												for (PojoTag t in tags) Padding(
													padding: const EdgeInsets.only(top: 2, left:2),
													child: Container(
														decoration: BoxDecoration(
															borderRadius: BorderRadius.all(Radius.circular(20)),
															color: t.name == "Thera" ? HazizzTheme.kreta_homeworkColor : Colors.grey,
														),
														child: Padding(
															padding: const EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 5),
															child: Text(t.getDisplayName(context), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),),
														),
													),
												)
											] //tagWidgets
										),
									),
								],
							),

							Builder(
								builder: (context){
									if(task.subject == null){
										return Container();
									}
									return Padding(
										padding: const EdgeInsets.only(top: 3, left: 2),
										child: Container(
												decoration: BoxDecoration(
													borderRadius: BorderRadius.all(Radius.circular(6)),
													color: mainColor,
												),
												child: Padding(
													padding: const EdgeInsets.only(left: 5, right: 4),
													child: Text(task.subject.name,
														style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),),
												)
										),
									);
								},
							),

							Builder(
								builder: (context){
									if(task.title == null) return Container();
									return Row(
										children: [
											Padding(
												padding: const EdgeInsets.only(left: 6),
												child: Text(task.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),),
											),
										]
									);
								},
							),

							Padding(
								padding: const EdgeInsets.only(right: 20, top: 0, bottom: 0),
								// child: Text(markdownImageRemover(pojoTask.description), style: TextStyle(fontSize: 18),),
								child: Builder(
									builder: (context){

										if(task.description.length >= 200){

										}
										return Stack(
											children: [
												ConstrainedBox(
													constraints: BoxConstraints(),
													child: Builder(
														builder: (context){
															Color textColor = Colors.black;
															if(HazizzTheme.currentThemeIsDark){
																textColor = Colors.white;
															}
															return Transform.translate(
																offset: const Offset(-6, -9),
																child: Markdown(data: task.description,
																	padding:  const EdgeInsets.only(left: 20, top: 12),
																	shrinkWrap: true,
																	physics: NeverScrollableScrollPhysics(),
																	imageBuilder: (uri){

																		final List<String> a = uri.toString().split("?id=");
																		final String id = a.length > 1 ? a[1] : null;

																		if(id != null){
																			return Padding(
																				padding: const EdgeInsets.only(left: 2, right: 2, bottom: 4),
																				child: Container(
																					height: 60,
																					child: ClipRRect(
																						child: Image.network( "https://drive.google.com/thumbnail?id=$id",
																							loadingBuilder: (context, child, progress){
																								return progress == null
																										? child
																										: CircularProgressIndicator();
																							},
																						),
																						borderRadius: BorderRadius.circular(3),
																					),
																				),
																			);
																		}

																		return Padding(
																			padding: const EdgeInsets.only(left: 2, right: 2, bottom: 4),
																			child: Container(
																				height: 60,
																				child: ClipRRect(
																					child: Image.network(uri.toString(),
																						loadingBuilder: (context, child, progress){
																							return progress == null
																									? child
																									: CircularProgressIndicator();
																						},
																					),
																					borderRadius: BorderRadius.circular(3),
																				),

																			),
																		);
																	},

																	onTapLink: (String url) async {
																		await Navigator.pushNamed(context, "/viewTask", arguments: task.copy());
																	},

																	styleSheet: MarkdownStyleSheet(
																		p:  TextStyle(fontFamily: "Nunito", fontSize: 14, color: textColor),
																		h1: TextStyle(fontFamily: "Nunito", fontSize: 26, color: textColor),
																		h2: TextStyle(fontFamily: "Nunito", fontSize: 24, color: textColor),
																		h3: TextStyle(fontFamily: "Nunito", fontSize: 22, color: textColor),
																		h4: TextStyle(fontFamily: "Nunito", fontSize: 20, color: textColor),
																		h5: TextStyle(fontFamily: "Nunito", fontSize: 18, color: textColor),
																		h6: TextStyle(fontFamily: "Nunito", fontSize: 16, color: textColor),
																		a:  TextStyle(fontFamily: "Nunito", color: Colors.blue, decoration: TextDecoration.underline),
																	),
																),
															);
														},
													),
												),
											]
										);
									},
								)
							),

							Row(
								mainAxisAlignment: MainAxisAlignment.end,
								children: <Widget>[
									Padding(
										padding: const EdgeInsets.only(top: 1, right: 6),
										child: Text(task.creator.displayName, style: theme(context).textTheme.subtitle2,),
									),
								],
							)
						],
					),
				)
		);
	}
}

*/