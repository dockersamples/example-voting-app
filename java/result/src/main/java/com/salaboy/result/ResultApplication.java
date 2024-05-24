package com.salaboy.result;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.util.HtmlUtils;

import io.diagrid.springboot.dapr.core.DaprKeyValueTemplate;

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


