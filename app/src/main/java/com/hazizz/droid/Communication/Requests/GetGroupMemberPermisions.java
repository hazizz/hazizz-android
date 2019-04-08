package com.hazizz.droid.Communication.Requests;

import android.app.Activity;
import android.util.Log;

import com.hazizz.droid.Communication.POJO.Response.CustomResponseHandler;
import com.hazizz.droid.Communication.POJO.Response.PojoPermisionUsers;
import com.hazizz.droid.Communication.Requests.Parent.Request;

import okhttp3.ResponseBody;
import retrofit2.Response;

public class GetGroupMemberPermisions extends Request {
    private String p_groupId;
    public GetGroupMemberPermisions(Activity act, CustomResponseHandler rh, long p_groupId) {
        super(act, rh);
        Log.e("hey", "created GetGroupMemberPermisions object");
        this.p_groupId = Long.toString(p_groupId);
    }
    @Override public void makeCall() {
        call(act,  thisRequest, call, cOnResponse, gson);
    }
    public void setupCall() {
        headerMap.put(HEADER_AUTH, getHeaderAuthToken());
        call = aRequest.getGroupMemberPermissions(p_groupId, headerMap);
    }
    @Override
    public void callIsSuccessful(Response<ResponseBody> response) {
        PojoPermisionUsers pojo = gson.fromJson(response.body().charStream(), PojoPermisionUsers.class);
        cOnResponse.onPOJOResponse(pojo);
    }
}