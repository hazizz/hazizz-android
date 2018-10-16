package com.indeed.hazizz.Fragments;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.indeed.hazizz.Activities.MainActivity;
import com.indeed.hazizz.Communication.MiddleMan;
import com.indeed.hazizz.Communication.POJO.Response.CustomResponseHandler;
import com.indeed.hazizz.Communication.POJO.Response.POJOerror;
import com.indeed.hazizz.Listviews.GroupList.CustomAdapter;
import com.indeed.hazizz.R;
import com.indeed.hazizz.Transactor;

import java.util.HashMap;

public class AddToGroupFragment extends Fragment {

    private View v;
    private CustomAdapter adapter;
    private EditText editText_memberName;
    private Button button_addMember;
    private TextView editText_infoGroup;
    private TextView textView_error;

    private int groupId;
    private String groupName;

    private boolean destCreateTask = false;

    CustomResponseHandler rh = new CustomResponseHandler() {

        @Override
        public void onResponse(HashMap<String, Object> response) {

        }

        @Override
        public void onPOJOResponse(Object response) {
        }
        @Override
        public void onFailure() {
            Log.e("hey", "4");
            Log.e("hey", "got here onFailure");
            button_addMember.setEnabled(true);
        }


        @Override
        public void onEmptyResponse() {

        }

        @Override
        public void onSuccessfulResponse() {
            goBack();
        }

        @Override
        public void onErrorResponse(POJOerror error) {
            //  textView.append("\n errorCode: " + error.getErrorCode());
            if(error.getErrorCode() == 2){ // validation failed
                //  textView_error.setText("Helytelen jelszó");
            }
            if(error.getErrorCode() == 31){ // no such user
                textView_error.setText("Felhasználó nem található");
            }
            Log.e("hey", "errodCOde is " + error.getErrorCode() + "");
            Log.e("hey", "got here onErrorResponse");
            button_addMember.setEnabled(true);
        }
    };


    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        v = inflater.inflate(R.layout.fragment_addtogroup, container, false);
        ((MainActivity)getActivity()).onFragmentCreated();
        groupId = getArguments().getInt("groupId");
        groupName = getArguments().getString("groupName");

        editText_memberName = v.findViewById(R.id.editText_memberName);
        button_addMember = v.findViewById(R.id.button_addMember);
        editText_infoGroup = v.findViewById(R.id.textView_infoGroup);
        editText_infoGroup.append(groupName);
        textView_error = v.findViewById(R.id.textView_error);

        button_addMember.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(editText_memberName.getTextSize() != 0) {
                    HashMap<String, Object> body = new HashMap<>();
                    body.put("userId", editText_memberName.getText().toString());

                    HashMap<String, Object> vars = new HashMap<>();
                    vars.put("groupId", groupId);
                    MiddleMan.newRequest(getActivity(), "inviteToGroup", body, rh, vars);
                    button_addMember.setEnabled(false);
                }else{
                    // TODO subject name not long enough
                    Log.e("hey", "else 123");
                }
            }
        });
        return v;
    }

    public void goBack(){
        Transactor.fragmentCreateTask(getFragmentManager().beginTransaction(), groupId, groupName);
    }
}
