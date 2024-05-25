package com.salaboy.worker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@EnableScheduling
@ComponentScan("io.dapr.springboot")
@ComponentScan("com.salaboy.worker")
@RestController
public class WorkerApplication {


	public static void main(String[] args) {
		SpringApplication.run(WorkerApplication.class, args);
	}
	
	@GetMapping("/")
	public String ok(){
		return "OK";
	}
	


 
}


