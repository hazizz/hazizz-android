package com.hazizz.droid.Fragments.GroupTabs;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentManager;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;

import com.hazizz.droid.Cache.MeInfo.MeInfo;
import com.hazizz.droid.Communication.POJO.Response.CustomResponseHandler;
import com.hazizz.droid.Communication.POJO.Response.POJOMembersProfilePic;
import com.hazizz.droid.Communication.POJO.Response.POJOerror;
import com.hazizz.droid.Communication.POJO.Response.POJOuser;
import com.hazizz.droid.Communication.POJO.Response.PojoPermisionUsers;
import com.hazizz.droid.Communication.Requests.GetGroupMemberPermisions;
import com.hazizz.droid.Communication.Strings;
import com.hazizz.droid.Fragments.ParentFragment.ParentFragment;
import com.hazizz.droid.Listviews.UserList.CustomAdapter;
import com.hazizz.droid.Listviews.UserList.UserItem;
import com.hazizz.droid.Manager;
import com.hazizz.droid.Communication.MiddleMan;
import com.hazizz.droid.R;
import com.hazizz.droid.Transactor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class GetGroupMembersFragment extends ParentFragment {

    private List<UserItem> listUser;
    private View v;
    private CustomAdapter adapter;
    private int groupId;
    private List<POJOMembersProfilePic> userProfilePics = new ArrayList<POJOMembersProfilePic>();

    private TextView textView_noContent;
    private SwipeRefreshLayout sRefreshLayout;


    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        v = inflater.inflate(R.layout.fragment_getgroupmembers, container, false);

        fragmentSetup();

        groupId = GroupTabFragment.groupId;
        textView_noContent = v.findViewById(R.id.textView_noContent);

        sRefreshLayout = v.findViewById(R.id.swipe_refresh_layout);
        sRefreshLayout.bringToFront();
        sRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                getUser();
            }});
        sRefreshLayout.setColorSchemeColors(getResources().getColor(R.color.colorPrimaryDarkBlue), getResources().getColor(R.color.colorPrimaryLightBlue), getResources().getColor(R.color.colorPrimaryDarkBlue));
        createViewList();
        getUser();

        return v;
    }

    public void getUser() {
        CustomResponseHandler responseHandler = new CustomResponseHandler() {
            @Override
            public void onPOJOResponse(Object response) {
                adapter.clear();
                textView_noContent.setVisibility(v.INVISIBLE);
                PojoPermisionUsers pojoPermisionUser = (PojoPermisionUsers)response;
                HashMap<Integer, POJOMembersProfilePic> profilePicMap = Manager.ProfilePicManager.getCurrentGroupMembersProfilePic();

                MeInfo meInfo = MeInfo.getInstance();
                if(pojoPermisionUser != null) {
                    if(pojoPermisionUser.getOWNER() != null) {
                        for (POJOuser u : pojoPermisionUser.getOWNER()) {
                            try {
                                listUser.add(new UserItem(u.getId(),u.getDisplayName(), u.getUsername(), profilePicMap.get(u.getId()).getData(), Strings.Rank.OWNER.getValue()));
                            } catch (NullPointerException e) {
                                listUser.add(new UserItem(u.getId(),u.getDisplayName(), u.getUsername(), null, Strings.Rank.OWNER.getValue()));
                            }
                            if(u.getId() == meInfo.getUserId()){
                                meInfo.setRankInCurrentGroup(Strings.Rank.OWNER);
                            }
                            Log.e("hey", "555: OWNER");
                            Manager.GroupRankManager.setRank(u.getId(), Strings.Rank.OWNER);
                        }
                    }
                    if(pojoPermisionUser.getMODERATOR() != null) {
                        for (POJOuser u : pojoPermisionUser.getMODERATOR()) {
                            try {
                                listUser.add(new UserItem(u.getId(),u.getDisplayName(),u.getUsername(), profilePicMap.get(u.getId()).getData(), Strings.Rank.MODERATOR.getValue()));
                            } catch (NullPointerException e) {
                                listUser.add(new UserItem(u.getId(),u.getDisplayName(),u.getUsername(), null, Strings.Rank.MODERATOR.getValue()));
                            }
                            if(u.getId() == meInfo.getUserId()){
                                meInfo.setRankInCurrentGroup(Strings.Rank.MODERATOR);
                            }
                            Log.e("hey", "555: MODI");
                            Manager.GroupRankManager.setRank(u.getId(), Strings.Rank.MODERATOR);
                        }
                    }
                    if(pojoPermisionUser.getUSER() != null) {
                        for (POJOuser u : pojoPermisionUser.getUSER()) {
                            try {
                                listUser.add(new UserItem(u.getId(),u.getDisplayName(),u.getUsername(), profilePicMap.get(u.getId()).getData(), Strings.Rank.USER.getValue()));
                            } catch (NullPointerException e) {
                                listUser.add(new UserItem(u.getId(),u.getDisplayName(),u.getUsername(), null, Strings.Rank.USER.getValue()));
                            }
                            if(u.getId() == meInfo.getUserId()){
                                meInfo.setRankInCurrentGroup(Strings.Rank.USER);
                            }
                            Log.e("hey", "555: USER");
                            Manager.GroupRankManager.setRank(u.getId(), Strings.Rank.USER);
                        }
                    }

                }else{
                    textView_noContent.setVisibility(View.VISIBLE);
                }
                adapter.notifyDataSetChanged();
                sRefreshLayout.setRefreshing(false);
            }

            @Override public void onErrorResponse(POJOerror error) {
                Log.e("hey", "onErrorResponse");
                sRefreshLayout.setRefreshing(false);
            }
            @Override public void onNoConnection(){
                textView_noContent.setText(R.string.info_noInternetAccess);
                textView_noContent.setVisibility(View.VISIBLE);
                sRefreshLayout.setRefreshing(false);
            }
        };
        MiddleMan.newRequest(new GetGroupMemberPermisions(getActivity(), responseHandler, groupId));
    }

    void createViewList(){
        listUser = new ArrayList<>();

        ListView listView = (ListView)v.findViewById(R.id.listView_getGroupMembers);

        adapter = new CustomAdapter(getActivity(), R.layout.user_item, listUser);
        listView.setAdapter(adapter);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                Transactor.fragmentDialogShowUserDetailDialog(getFragmentManager().beginTransaction(), adapter.getItem(i).getId(), adapter.getItem(i).getUserRank(),
                        adapter.getItem(i).getUserProfilePic());
                        // Manager.ProfilePicManager.getCurrentGroupMembersProfilePic().get((int)adapter.getItem(i).getId()).getData());
            }
        });
    }

    public void openInviteLinkDialog(FragmentManager fm){
        Transactor.fragmentDialogInviteLink(fm.beginTransaction(), GroupTabFragment.groupId, GroupTabFragment.groupName);
    }

}