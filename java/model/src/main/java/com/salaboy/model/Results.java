package com.salaboy.model;

import org.springframework.data.annotation.Id;

public class Results {
    
    @Id
    private String id;
    private Integer optionA;
    private Integer optionB;

    
    public Results() {
    }

    
    public Results(String id, Integer optionA, Integer optionB) {
        this.id = id;
        this.optionA = optionA;
        this.optionB = optionB;
    }


    public Results(Integer optionA, Integer optionB) {
        this.optionA = optionA;
        this.optionB = optionB;
    }


    public Integer getOptionA() {
        return optionA;
    }
    public void setOptionA(Integer optionA) {
        this.optionA = optionA;
    }
    public Integer getOptionB() {
        return optionB;
    }
    public void setOptionB(Integer optionB) {
        this.optionB = optionB;
    }


    public String getId() {
        return id;
    }


    public void setId(String id) {
        this.id = id;
    }

    
}
