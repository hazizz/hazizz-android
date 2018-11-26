package com.indeed.hazizz.Listviews.UserList;

import com.indeed.hazizz.Communication.POJO.Response.getTaskPOJOs.POJOcreator;
import com.indeed.hazizz.Communication.POJO.Response.getTaskPOJOs.POJOgroupData;
import com.indeed.hazizz.Communication.POJO.Response.getTaskPOJOs.POJOsubjectData;

import lombok.Data;

@Data
public class UserItem {

    String userName;
    String userProfilePic;

    public UserItem(String userName, String userProfilePic){
        this.userName = userName;
        this.userProfilePic = userProfilePic;
    }
}

