// EZT NÉZD MEG -->https://github.com/Solido/awesome-flutter
import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile/communication/requests/request_collection.dart';
import 'package:mobile/custom/hazizz_logger.dart';
import 'package:mobile/managers/app_state_manager.dart';
import 'package:mobile/managers/token_manager.dart';
//import 'package:mobile/packages/hazizz-dio-2.1.3/lib/dio.dart';
import 'package:mobile/communication/hazizz_response.dart';
import 'connection.dart';
import 'custom_response_errors.dart';
import 'htttp_methods.dart';


Future<HazizzResponse> getResponse(Request request)async{
  return await RequestSender().getResponse(request);
}

class RequestSender{
  static final RequestSender _instance = new RequestSender._internal();
  
  bool _isLocked = false;

  factory RequestSender() {
    return _instance;
  }

  RequestSender._internal(){

    dio.interceptors.add(InterceptorsWrapper(
      onRequest:(RequestOptions options) async{
        // Do something before request is sent
        /*
        dio.interceptors.requestLock.lock();
        dio.clear();
        */
        /*
        connectivity = await Connectivity().checkConnectivity();
        if(!(connectivity == ConnectivityResult.wifi ||connectivity == ConnectivityResult.mobile)){
          dio.lock();
        }
        */
        HazizzLogger.printLog("preparing to send request");
        return options; //continue
        // If you want to resolve the request with some custom data，
        // you can return a `Response` object or return `dio.resolve(data)`.
        // If you want to reject the request with a error message,
        // you can return a `DioError` object or return `dio.reject(errMsg)`
      },
      onResponse:(Response response) {
        HazizzLogger.printLog("got response: ${response.data}");

        return response; // continue
      },
      onError: (DioError e) async{
        HazizzLogger.printLog("got response error: ${e}");
        // return  e;//continue
      }
    ));
  }
  /*
      String method,
      int connectTimeout,
      int sendTimeout,
      int receiveTimeout,
      Iterable<Cookie> cookies,
      Map<String, dynamic> extra,
      Map<String, dynamic> headers,
      ResponseType responseType,
      ContentType contentType,
      ValidateStatus validateStatus,
      bool receiveDataWhenStatusError,
      bool followRedirects,
      int maxRedirects,
  */
  final Options options = new Options(
    /*
    responseDecoder: (List<int> responseBytes, RequestOptions options, ResponseBody responseBody){
      responseBody.
    },
    */

    connectTimeout: 6000,
    sendTimeout: 6000,
    receiveTimeout: 6000,
  //  headers: request.header,
    responseType: ResponseType.plain,
    receiveDataWhenStatusError: true,
    followRedirects: true,


  );

  Dio dio = new Dio();


  void initalize(){
    dio = new Dio();
    dio.transformer = new FlutterTransformer();
    HazizzLogger.hprint("dio options: ${options.toString()}");
  }

  Future<void> waitCooldown() async{
    dio.interceptors.requestLock.lock();
    await new Future.delayed(const Duration(milliseconds: 1000));
    dio.interceptors.requestLock.unlock();
  }
  void lock(){
    dio.lock();
    _isLocked = true;
    HazizzLogger.printLog("dio interceptors: locked");


  }
  void unlock(){
    dio.unlock();
    _isLocked = false;
    HazizzLogger.printLog("dio interceptors: unlocked");

  }
  bool isLocked(){
    return _isLocked;
  }
  Future<HazizzResponse> getAuthResponse(AuthRequest authRequest) async{
    HazizzResponse hazizzResponse;
    try{
      options.headers = await authRequest.buildHeader();
      Dio authDio = Dio();
      Response response = await authDio.post(authRequest.url, queryParameters: authRequest.query, data: authRequest.body, options: options);
      hazizzResponse = HazizzResponse.onSuccess(response: response, request: authRequest);

      HazizzLogger.printLog("hey: sent token request");
    }on DioError catch(error){
      if(error.response != null) {
        HazizzLogger.printLog("log: error response data: ${error.response.data}");
      }
      hazizzResponse = await HazizzResponse.onError(dioError: error, request: authRequest);
      if(hazizzResponse.pojoError != null){
        if(hazizzResponse.pojoError.errorCode == 21){
          await AppState.logout();
        }
      }


      HazizzLogger.printLog("auth response is successful: ${hazizzResponse.isSuccessful}");
    }
    return hazizzResponse;
  }

  Set<Request> noConnectionRequestsPrioritized = Set();
  List<Request> noConnectionRequests = List();

  void addToPendingList(Request newRequest){

    if(newRequest is CreateToken){
      noConnectionRequestsPrioritized.add(newRequest);
    }

    if(noConnectionRequests.isNotEmpty){
      for(int i = 0; i < noConnectionRequests.length; i++){
        if(noConnectionRequests[i] == newRequest){
          noConnectionRequests[i] = newRequest;
        }
      }
    }else{
      noConnectionRequests.add(newRequest);
    }
  }

  Future sendPendingRequests() async {
    for(Request request in noConnectionRequestsPrioritized){
      await RequestSender().getResponse(request);
    }
    for(Request request in noConnectionRequests){
      await RequestSender().getResponse(request);
    }
  }

  Future clearPending() async {

    noConnectionRequestsPrioritized.clear();
    noConnectionRequests.clear();
  }

  Future clearQueue() async {
    await dio.clear();
  }

  clearAllRequests() async {
    await clearPending();
    await clearQueue();
  }



  Future<HazizzResponse> getResponse(Request request) async{


    if((await TokenManager.getLastTokenUpdateTime()).difference(DateTime.now()).inHours >= 23){
      await TokenManager.createTokenWithRefresh();
    }


    HazizzResponse hazizzResponse;

    Response response;

    HazizzLogger.printLog("about to start sending request: ${request.toString()}");

    if(isLocked()) HazizzLogger.printLog("Dio interceptor is locked: ${request.toString()}");

    bool isConnected = await Connection.isOnline();
    try {
      if(isConnected) {
        HazizzLogger.printLog("request query: ${request.query}");
        HazizzLogger.printLog("request url: ${request.url}");

        if(request.httpMethod == HttpMethod.GET) {
          options.headers = await request.buildHeader();
          response = await dio.get(request.url, queryParameters: request.query, options: options);

        }else if(request.httpMethod == HttpMethod.POST) {
          options.headers = await request.buildHeader();
          response = await dio.post(request.url, queryParameters: request.query, data: request.body, options: options);
        }else if(request.httpMethod == HttpMethod.DELETE) {
          options.headers = await request.buildHeader();
          response = await dio.delete(request.url, queryParameters: request.query, data: request.body, options: options);
        }else if(request.httpMethod == HttpMethod.PATCH) {
          options.headers = await request.buildHeader();
          response = await dio.patch(request.url, queryParameters: request.query, data: request.body, options: options);
        }

        HazizzLogger.printLog("request was sent successfully: ${request.toString()}");
        HazizzLogger.printLog("response for ${request.toString()}: ${response.toString()}");
        hazizzResponse = HazizzResponse.onSuccess(response: response, request: request);
       // HazizzLogger.printLog("log: request sent: ${request.toString()}");
        HazizzLogger.printLog("HazizzResponse.onSuccess ran: ${request.toString()}");

      }else{
        HazizzLogger.printLog("No network connection, can't send request: ${request.toString()}");
        throw noConnectionError;
      }
    }on DioError catch(error) {
      HazizzLogger.printLog("response is error: ${request.toString()}");

      hazizzResponse = await HazizzResponse.onError(dioError: error, request: request);
      HazizzLogger.printLog("HazizzResponse.onError ran: ${request.toString()}");

    }
    return hazizzResponse;
  }
}