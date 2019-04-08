package com.hazizz.droid.Listviews.TheraUserList;

import android.app.Activity;
import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.hazizz.droid.R;

import java.util.List;

public class CustomAdapter extends ArrayAdapter<TheraUserItem> {

    int picID;
    Context context;
    List<TheraUserItem> data = null;


    public CustomAdapter(@NonNull Context context, int resource, @NonNull List<TheraUserItem> objects) {
        super(context, resource, objects);

        this.picID = resource;
        this.context = context;
        this.data = objects;
    }

    static class DataHolder{
        TextView textView_id;
        TextView textView_status;
        TextView textView_url;
        TextView textView_username;
    }
    @NonNull
    @Override
    public View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
        DataHolder holder = null;

        if(convertView == null) {
            LayoutInflater inflater = ((Activity) context).getLayoutInflater();

            convertView = inflater.inflate(picID, parent, false);

            holder = new DataHolder();
            holder.textView_id = convertView.findViewById(R.id.textView_subjectName);
            holder.textView_status = convertView.findViewById(R.id.textView_status);
            holder.textView_url = convertView.findViewById(R.id.textView_weight);
            holder.textView_username = convertView.findViewById(R.id.textView_username);


            convertView.setTag(holder);
        }else{
            holder = (DataHolder)convertView.getTag();
        }

        TheraUserItem th_userItem = data.get(position);

        holder.textView_id.setText("" + th_userItem.getId());
        holder.textView_url.setText(th_userItem.getUrl());
        holder.textView_status.setText(th_userItem.getStatus());
        holder.textView_username.setText(th_userItem.getUsername());

        return convertView;
    }
}