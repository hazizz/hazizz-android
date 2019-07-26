import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
//import 'package:mobile/packages/hazizz-dio-2.1.3/lib/dio.dart';
//import 'package:mobile/packages/hazizz-dio-2.1.3/lib/dio.dart';

//import 'package:dio/dio.dart';

import 'RequestSender.dart';
import 'communication/ResponseHandler.dart';
import 'communication/pojos/PojoError.dart';
import 'communication/pojos/PojoTokens.dart';
import 'communication/requests/request_collection.dart';
import 'managers/token_manager.dart';
import 'managers/cache_manager.dart';

class HazizzResponse{

  bool isSuccessful = false;
  bool isError = false;
  bool hasPojoError = false;

  Request request;

  Response response;

 // Function convertData;

  dynamic convertedData;

  DioError dioError;

  PojoError pojoError;

  HazizzResponse._();

  static HazizzResponse onSuccess({@required Response response, @required Request request}){
    print("log: header2: ${response.headers.toString()}");
    HazizzResponse hazizzResponse = new HazizzResponse._();
    print("im alive 1");
    hazizzResponse.response = response;
    print("im alive 2");
    hazizzResponse.request = request;
    print("im alive 3");
    print("im alive ${request}");
    hazizzResponse.convertedData = request.convertData(response);
    print("im alive 4");
    hazizzResponse.isSuccessful = true;
    print("im alive 5");
    return hazizzResponse;
  }

  static Future<HazizzResponse> onError({@required DioError dioError, @required Request request})async{
  //  _onErrorResponse(dioError);
    HazizzResponse hazizzResponse = new HazizzResponse._();
    hazizzResponse.dioError = dioError;
    hazizzResponse.response = dioError.response;
    hazizzResponse.request = request;
    hazizzResponse.isError = true;
    await hazizzResponse.onErrorResponse();
    return hazizzResponse;
  }

  onErrorResponse()async {
    print("log: dioError: ${dioError.type}");
    if(response != null) {
      print("log: error response data: ${response.data}");
      pojoError = PojoError.fromJson(json.decode(response?.data));

      if(pojoError != null){
        hasPojoError = true;
        if(pojoError.errorCode == 19) { // to many requests
          print("here iam");
          await RequestSender().waitCooldown();
        }
        else if(pojoError.errorCode == 18 ||
            pojoError.errorCode == 17) { // wrong token
          // a requestet elmenteni hogy újra küldje
          print("hey: Locked: ${RequestSender().isLocked()}");
          if(!RequestSender().isLocked()) {
            RequestSender().lock();

            HazizzResponse tokenResponse = await RequestSender().getTokenResponse(
                new CreateTokenWithRefresh(
                    b_username: await InfoCache.getMyUsername(),
                    b_refreshToken: await TokenManager.getRefreshToken(),
                    rh: ResponseHandler(
                        onSuccessful: (dynamic data) {
                          print("hey: got token reponse: ${data.token}");
                          RequestSender().unlock();
                        },
                        onError: (PojoError pojoError) {
                          RequestSender().unlock();
                        }
                    )
                ));

            if(tokenResponse.isSuccessful) {
              PojoTokens tokens = tokenResponse.convertedData;
              TokenManager.setToken(tokens.token);
              TokenManager.setRefreshToken(tokens.refresh);
              RequestSender().unlock();
            }else {
              print("log: obtaining token failed");
            }


            // elküldi újra ezt a requestet ami errort dobott
            RequestSender().getResponse(request);
            print("hey2: username: ${await InfoCache.getMyUsername()}");
            print("hey2: token: ${await TokenManager.getRefreshToken()}");
          }else {
            RequestSender().getResponse(request);
          }
        }else if(pojoError.errorCode == 13 || pojoError.errorCode == 14 ||
            pojoError.errorCode == 15) {
          // navigate to login/register page
        }
        print("log: response error: ${pojoError.toString()}");
        // throw new HResponseError(pojoError);
        //  return pojoError;
        //request.onError(pojoError);
      }
      else{
        if(dioError.type == DioErrorType.CONNECT_TIMEOUT){
          dioError.response.headers.contentType.toString();
        }
      }
    }
  }
}