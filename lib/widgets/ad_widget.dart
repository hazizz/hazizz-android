import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mobile/custom/hazizz_localizations.dart';
import 'package:mobile/managers/preference_service.dart';
import 'package:mobile/pages/settings_page/about_page.dart';
import 'package:mobile/services/facebook_opener.dart';
import 'package:mobile/widgets/card_header_widget.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:url_launcher/url_launcher.dart';

enum AdType{
  fel_elek,
  facebook,
  giveaway,
  hazizz_meet,
  vakacio,
}

Widget showAd(BuildContext context, {bool show = true, bool showHeader = false}){
  if(PreferenceService.enabledAd && show){
    if(showHeader) return StickyHeader(
      header: CardHeaderWidget(text: localize(context, key: "ad"),),
      content: AdWidget(),
    );
    return AdWidget();
  }
  return Container();
}


class AdWidget extends StatefulWidget {

  static const String ad_fel_elek = "assets/images/fel_elek_ad_banner.png";
  static const String ad_facebook = "assets/images/facebook_ad_banner.png";
  static const String ad_giveaway = "assets/images/giveaway_ad_banner.png";
  static const String ad_hazizz_meet = "assets/images/hazizz_meet_ad_banner.png";
  static const String ad_hazizz_vakacio = "assets/images/hazizz_meet_ad_banner.png";


  /*
  double chance;
  int index;

  AdWidget.byChance({Key key, chance = 5}) : super(key: key){
    bool _show = false;

    int r = Random().nextInt(chance);

    if(r == 0){
      _show = true;
    }
    AdManager.allowed.add(_show);
    index = AdManager.allowed.length-1;
  }
  */

  AdWidget({Key key, chance}) : super(key: key);

  @override
  _AdWidgetState createState() => _AdWidgetState();
}

class _AdWidgetState extends State<AdWidget> {

  AdType adType;
  Timer timer;

  DateTime now = DateTime.now();
  Duration durationUntilVakacio;

  DateTime vakacioDate;

  @override
  void initState() {
    vakacioDate = DateTime(now.year, 6, 16);
    durationUntilVakacio = vakacioDate.difference(now);
    setTimer(now.add(Duration(seconds: 1)));
    chooseType();
    super.initState();
  }

  void chooseType(){
    int r = Random().nextInt(5);
    if(r == 0){
      adType = AdType.fel_elek;
    }else if(r == 1){
      adType = AdType.facebook;
    }else if(r == 2 || r == 3 || r == 4){
       adType = AdType.vakacio;
    }else{
      /*
      if(r == 3 && DateTime.now().isBefore(DateTime(2020, 04, 17, 23, 59))){
        adType = AdType.giveaway;
      }else if(r == 4
          && DateTime.now().isBefore(DateTime(2020, 04, 1, 23, 59))
          && DateTime.now().isAfter(DateTime(2020, 04, 1, 0, 0))
      ){
        adType = AdType.hazizz_meet;
      }
      else{
        int r2 = Random().nextInt(2);
        if(r2 == 0){
          adType = AdType.fel_elek;
        }else{
          adType = AdType.facebook;
        }
      }
      */
    }
  }

  String chooseImage(){
    if(adType == AdType.facebook){
      return AdWidget.ad_facebook;
    }if(adType == AdType.fel_elek){
      return AdWidget.ad_fel_elek;
    }if(adType == AdType.giveaway){
      return AdWidget.ad_giveaway;
    }if(adType == AdType.hazizz_meet){
      return AdWidget.ad_hazizz_meet;
    }if(adType == AdType.vakacio){
      return AdWidget.ad_hazizz_vakacio;
    }
  }

  void setTimer(DateTime nextEventChangeTime2){
    void handleTimeout() {
      setState(() {
        now = DateTime.now();
        durationUntilVakacio = vakacioDate.difference(now);
      });
      setTimer(nextEventChangeTime2.add(Duration(seconds: 1)));
    }

    var duration = (nextEventChangeTime2.difference(now));
    timer = new Timer(duration, handleTimeout);
  }

  Widget vakacioWidget(){
    final String vakacioLocalized = "vakacio".localize(context);

    /*
    HazizzLogger.printLog("sadfsdg: "+ vakacioLocalized.length.toString());
    HazizzLogger.printLog("sadfsdg2: "+ durationUntilVakacio.inDays.toString());
    */

    int off = 0;

    if(durationUntilVakacio.inDays <= vakacioLocalized.length){
      off = durationUntilVakacio.inDays - vakacioLocalized.length;
    }

    return Stack(
      children: <Widget>[
        Image.asset(
          chooseImage(),
          fit: BoxFit.fitWidth,
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if(!durationUntilVakacio.isNegative)
              Text("vakacio_until".localize(context, args: [
                durationUntilVakacio.inDays.toString(),
                (durationUntilVakacio.inHours - durationUntilVakacio.inDays * 24).toString(),
                (durationUntilVakacio.inMinutes - (durationUntilVakacio.inHours * 60)).toString(),
                (durationUntilVakacio.inSeconds - (durationUntilVakacio.inMinutes * 60)).toString()
              ]), textAlign: TextAlign.center, style: TextStyle(fontSize: 16, letterSpacing: 1.6)),
            Text(vakacioLocalized.substring(vakacioLocalized.length - off, vakacioLocalized.length),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, letterSpacing: 4),)
          ],
        )
      ],
    );
  }


  String chooseUrl(){
    if(adType == AdType.facebook){
      return AboutPage.fb_site;
    }
    else{
      return "https://play.google.com/store/apps/details?id=com.hazizz.dusza2019";
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        elevation: 5,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: <Widget>[
            adType != AdType.vakacio ? Image.asset(
              chooseImage(),
              fit: BoxFit.fitWidth,
            ) : vakacioWidget(),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    if(adType == AdType.facebook
                    || adType == AdType.hazizz_meet
                    ){
                      openFacebookPage();
                      return;
                    }

                    String url;
                    if(adType == AdType.fel_elek){
                      url = "https://play.google.com/store/apps/details?id=com.hazizz.dusza2019";
                    }if(adType == AdType.giveaway){
                      url = "https://www.facebook.com/notes/h%C3%A1zizz/h%C3%A1zizz-nyerem%C3%A9nyj%C3%A1t%C3%A9k/489579875054324/";
                    }

                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}