package com.salaboy.echo;


import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.boot.web.codec.CodecCustomizer;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.codec.CodecConfigurer;

import org.springframework.web.bind.annotation.*;

import io.cloudevents.CloudEvent;
import io.cloudevents.spring.webflux.CloudEventHttpMessageReader;
import io.cloudevents.spring.webflux.CloudEventHttpMessageWriter;


@SpringBootApplication
@ConfigurationPropertiesScan
public class EchoApplication {

	public static void main(String[] args) {
		SpringApplication.run(EchoApplication.class, args);
	}

}


@RestController
@RequestMapping("/")
class EchoController {

	private static final Logger logger = LoggerFactory.getLogger(EchoController.class);


	@PostMapping("events")
	CloudEvent echo(@RequestBody CloudEvent cloudEvent)  {

		logger.info("Echo CloudEvent: " + cloudEvent.toString());

		return cloudEvent;
	}

	@Configuration
	class CloudEventHandlerConfiguration implements CodecCustomizer {

    @Override
    public void customize(CodecConfigurer configurer) {
        configurer.customCodecs().register(new CloudEventHttpMessageReader());
        configurer.customCodecs().register(new CloudEventHttpMessageWriter());
    }

}

}
