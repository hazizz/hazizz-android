package com.indeed.hazizz.Fragments;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;

import com.indeed.hazizz.Activities.MainActivity;
import com.indeed.hazizz.Communication.MiddleMan;
import com.indeed.hazizz.Communication.POJO.Response.CustomResponseHandler;
import com.indeed.hazizz.Communication.POJO.Response.POJOMembersProfilePic;
import com.indeed.hazizz.Communication.POJO.Response.POJOerror;
import com.indeed.hazizz.Communication.POJO.Response.POJOgroup;
import com.indeed.hazizz.Communication.POJO.Response.POJOuser;
import com.indeed.hazizz.Listviews.UserList.CustomAdapter;
import com.indeed.hazizz.Listviews.UserList.UserItem;
import com.indeed.hazizz.ProfilePicManager;
import com.indeed.hazizz.R;
import com.indeed.hazizz.Transactor;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

import okhttp3.ResponseBody;
import retrofit2.Call;

public class GetGroupMembersFragment extends Fragment {

    private List<UserItem> listUser;
    private View v;
    private CustomAdapter adapter;
    private int groupId;
    private List<POJOMembersProfilePic> userProfilePics = new ArrayList<POJOMembersProfilePic>();


    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        v = inflater.inflate(R.layout.fragment_getgroupmembers, container, false);
        ((MainActivity)getActivity()).onFragmentCreated();

        groupId = getArguments().getInt("groupId");

        createViewList();
        getUser();

        return v;
    }

    public void getUser() {
        CustomResponseHandler responseHandler = new CustomResponseHandler() {
            @Override
            public void onResponse(HashMap<String, Object> response) {

            }

            @Override
            public void onPOJOResponse(Object response) {
                ArrayList<POJOuser> castedListFullOfPojos = (ArrayList<POJOuser>)response;
                HashMap<Integer, POJOMembersProfilePic> profilePicMap = ProfilePicManager.getCurrentGroupMembersProfilePic();
                for(POJOuser u : castedListFullOfPojos){
                    Log.e("hey" , "GETDATA, userId: " + u.getId() + ", data is: " + profilePicMap.get(u.getId()).getData());
                    listUser.add(new UserItem(u.getUsername(), profilePicMap.get(u.getId()).getData() ));
                }

                adapter.notifyDataSetChanged();
                Log.e("hey", "got response");
            }

            @Override
            public void onFailure(Call<ResponseBody> call, Throwable t) {
                Log.e("hey", "4");
                Log.e("hey", "got here onFailure");
            }

            @Override
            public void onErrorResponse(POJOerror error) {
                Log.e("hey", "onErrorResponse");
            }

            @Override
            public void onEmptyResponse() {

            }

            @Override
            public void onSuccessfulResponse() {

            }

            @Override
            public void onNoConnection() {

            }
        };
        HashMap<String, Object> vars = new HashMap<>();
        vars.put("groupId", Integer.toString(groupId));
        MiddleMan.newRequest(this.getActivity(),"getGroupMembers", null, responseHandler, vars);
    }



    private void parseProfilePicWithName(){
        if(userProfilePics.size() == 0 && listUser.size() == 0){
            for(UserItem i : listUser){
              //  i.setUserProfilePic();
            }
        }
    }

    void createViewList(){
        listUser = new ArrayList<>();

        ListView listView = (ListView)v.findViewById(R.id.listView_getGroupMembers);

        adapter = new CustomAdapter(getActivity(), R.layout.user_item, listUser);
        listView.setAdapter(adapter);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {

            }
        });
    }
}
