
import 'dart:convert';


import 'package:mobile/communication/pojos/PojoSession.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../request_sender.dart';
import 'cache_manager.dart';

class LoginError implements Exception{

}

class WrongUsernameException implements LoginError{
  @override
  String toString() => "WrongUsernameException";
}

class WrongPasswordException implements LoginError{
  @override
  String toString() => "WrongUsernameException";
}

class KretaSessionManager {

  static const String _keySession = "key_session";

  static PojoSession selectedSession;

//  static bool tokenIsValid = true;

  SharedPreferences prefs;

  static Future<bool> hasSelectedSession() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String session = prefs.getString(_keySession);
    return !(session == null || session == "");
  }

  /*
  static Future<List<PojoSession>> fetchSessions() async {
    dynamic responseData = await RequestSender().getResponse(new GetKretaSessions());
    if(responseData is List){
      return responseData;
    }else if(responseData is PojoError){
      int errorCode = responseData.errorCode;
      print("log: errorCode: $errorCode");
      return null;
    //  return responseData;
    }
    throw new UnexpectedResponse(responseData);
  }

  static Future<List<PojoSession>> createSession({@required String username, @required String password, @required String url}) async {
    dynamic responseData = await RequestSender().getResponse(new CreateKretaSessions(b_username: username, b_password: password, b_url: url));
    if(responseData is Response ){
      return responseData;
    }else if(responseData is PojoError){
      int errorCode = responseData.errorCode;
      print("log: errorCode: $errorCode");
      return null;
      //  return responseData;
    }
    throw new UnexpectedResponse(responseData);
  }
  */

  static Future<void> loadSelectedSession() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedSession = prefs.getString(_keySession);
    if(encodedSession != null) {
      Map jsonSession = json.decode(encodedSession);
      if(jsonSession != null) {
        selectedSession = PojoSession.fromJson(jsonSession);
      }
      return null;
    }
    return null;
  }


  static Future<PojoSession> getSelectedSession() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedSession = prefs.getString(_keySession);
    print("cached session1: ${encodedSession}");
    if(encodedSession != null) {
      Map jsonSession = json.decode(encodedSession);
      print("cached session2: ${jsonSession}");

      if(jsonSession != null) {
        print("cached session3: ${PojoSession.fromJson(jsonSession)}");

        return PojoSession.fromJson(jsonSession);
      }
      return null;
    }
    return null;
  }

  static Future<void> setSelectedSession(PojoSession session) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map jsonSession = session.toJson();

    bool success = await prefs.setString(_keySession, jsonEncode(jsonSession));
    if(success){
      selectedSession = session;
    }
  }
}