package com.salaboy.worker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
@ComponentScan("io.dapr.springboot")
@ComponentScan("com.salaboy.worker")
public class WorkerApplication {


	public static void main(String[] args) {
		SpringApplication.run(WorkerApplication.class, args);
	}


	


 
}


