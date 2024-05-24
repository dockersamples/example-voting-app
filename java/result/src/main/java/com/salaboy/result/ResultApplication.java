package com.salaboy.result;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@SpringBootApplication
@ComponentScan("io.dapr.springboot")
@ComponentScan("com.salaboy.result")
@EnableScheduling
@Controller
@RequestMapping("/")
public class ResultApplication {

	
	public static void main(String[] args) {
		SpringApplication.run(ResultApplication.class, args);
	}
 
	@GetMapping
	String renderHTML() {
		
		return "index.html";
	}

}


