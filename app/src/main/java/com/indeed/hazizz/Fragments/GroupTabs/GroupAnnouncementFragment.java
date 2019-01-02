package com.indeed.hazizz.Fragments.GroupTabs;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;

import com.indeed.hazizz.Activities.MainActivity;
import com.indeed.hazizz.Communication.MiddleMan;
import com.indeed.hazizz.Communication.POJO.Response.AnnouncementPOJOs.POJOAnnouncement;
import com.indeed.hazizz.Communication.POJO.Response.CustomResponseHandler;
import com.indeed.hazizz.Communication.POJO.Response.POJOerror;
import com.indeed.hazizz.Communication.Strings;
import com.indeed.hazizz.Listviews.AnnouncementList.AnnouncementItem;
import com.indeed.hazizz.Listviews.AnnouncementList.Group.CustomAdapter;
import com.indeed.hazizz.Manager;
import com.indeed.hazizz.R;
import com.indeed.hazizz.Transactor;

import java.util.ArrayList;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.List;

import okhttp3.ResponseBody;
import retrofit2.Call;

public class GroupAnnouncementFragment extends Fragment{

    private View v;
    private CustomAdapter adapter;
    private List<AnnouncementItem> listAnnouncement;

    private TextView textView_noContent;
    private SwipeRefreshLayout sRefreshLayout;

    private int groupId;
    private String groupName;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        v = inflater.inflate(R.layout.fragment_announcements, container, false);
        Log.e("hey", "announcement group fragment created");
        ((MainActivity)getActivity()).onFragmentCreated();
        groupId = getArguments().getInt("groupId");
        groupName = getArguments().getString("groupName");

        textView_noContent = v.findViewById(R.id.textView_noContent);
        sRefreshLayout = v.findViewById(R.id.swipe_refresh_layout); sRefreshLayout.bringToFront();
        sRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                getAnnouncements();
            }});

        createViewList();
        getAnnouncements();

        return v;
    }
    void createViewList(){
        listAnnouncement = new ArrayList<>();
        ListView listView = (ListView)v.findViewById(R.id.listView_announcementGroup);
        adapter = new CustomAdapter(getActivity(), R.layout.announcement_item, listAnnouncement);
        listView.setAdapter(adapter);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                groupName = ((AnnouncementItem)listView.getItemAtPosition(i)).getGroup().getName();
                    Transactor.fragmentViewAnnouncement(getFragmentManager().beginTransaction(),
                        ((AnnouncementItem)listView.getItemAtPosition(i)).getGroup().getId(),
                        ((AnnouncementItem)listView.getItemAtPosition(i)).getAnnouncementId(),
                        ((AnnouncementItem)listView.getItemAtPosition(i)).getGroup().getName(),
                            false, Manager.DestManager.TOGROUP);
            }
        });
    }
    private void getAnnouncements(){
        adapter.clear();
        CustomResponseHandler responseHandler = new CustomResponseHandler() {
            @Override
            public int hashCode() {
                return super.hashCode();
            }

            @Override
            public void onResponse(HashMap<String, Object> response) { }
            @Override
            public void onPOJOResponse(Object response) {
                ArrayList<POJOAnnouncement> pojoList = (ArrayList<POJOAnnouncement>) response;
                if(pojoList.size() == 0){
                    textView_noContent.setVisibility(v.VISIBLE);
                }else {
                    textView_noContent.setVisibility(v.INVISIBLE);
                    for (POJOAnnouncement t : pojoList) {
                        listAnnouncement.add(new AnnouncementItem(t.getTitle(),
                                t.getDescription(), t.getGroup(), t.getCreator(), t.getSubject(), t.getId()));
                        adapter.notifyDataSetChanged();
                        Log.e("hey", t.getId() + " " + t.getGroup().getId());
                    }
                    Log.e("hey", "got response");
                }
                sRefreshLayout.setRefreshing(false);
            }
            @Override
            public void onFailure(Call<ResponseBody> call, Throwable t) {
                Log.e("hey", "4");
                Log.e("hey", "got here onFailure");
                textView_noContent.setVisibility(v.VISIBLE);
                sRefreshLayout.setRefreshing(false);
            }
            @Override
            public void onErrorResponse(POJOerror error) {
                Log.e("hey", "onErrorResponse");
                sRefreshLayout.setRefreshing(false);
            }
            @Override
            public void onEmptyResponse() {
                sRefreshLayout.setRefreshing(false);
            }
            @Override
            public void onSuccessfulResponse() { }
            @Override
            public void onNoConnection() {
                textView_noContent.setText(R.string.info_noInternetAccess);
                textView_noContent.setVisibility(View.VISIBLE);
                sRefreshLayout.setRefreshing(false);
                //    textView_noContent.
            }
        };
        EnumMap<Strings.Path, Object> vars = new EnumMap<>(Strings.Path.class);
        vars.put(Strings.Path.GROUPID, Integer.toString(groupId));
        MiddleMan.newRequest(this.getActivity(),"getAnnouncementsFromGroup", null, responseHandler, vars);
    }

    public void toAnnouncementEditor(FragmentManager fm){
        Transactor.fragmentCreateAnnouncement(fm.beginTransaction(),groupId, groupName, Manager.DestManager.TOGROUP);

    }
}


