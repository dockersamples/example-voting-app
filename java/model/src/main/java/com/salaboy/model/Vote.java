package com.salaboy.model;

import org.springframework.data.annotation.Id;

public class Vote {
    
    @Id
    private String voterId;
    private String option;
    private String type;
    private String user;
    

    public Vote() {
    }

    public Vote(String type, String voterId, String option,  String user) {
        this.option = option;
        this.type = type;
        this.voterId = voterId;
        this.user = user;
    }
    public String getOption() {
        return option;
    }
    public void setOption(String option) {
        this.option = option;
    }
    public String getType() {
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }
    public String getVoterId() {
        return voterId;
    }
    public void setVoterId(String voterId) {
        this.voterId = voterId;
    }

    public String getUser() {
        return user;
    }

    public void setUser(String user) {
        this.user = user;
    }

    

    
}
