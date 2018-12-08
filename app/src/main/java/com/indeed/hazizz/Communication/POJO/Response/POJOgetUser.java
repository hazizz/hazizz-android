package com.indeed.hazizz.Communication.POJO.Response;


import lombok.Data;

@Data
public class POJOgetUser {

    private int id;
    private String username;
    private String registrationDate;

    public POJOgetUser(int id, String username, String registrationDate) {
        this.id = id;
        this.username = username;
        this.registrationDate = registrationDate;
    }
}
