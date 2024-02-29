package com.salaboy.echo.config;

import io.cloudevents.spring.mvc.CloudEventHttpMessageConverter;
import org.springframework.boot.autoconfigure.AutoConfigureBefore;
import org.springframework.boot.autoconfigure.condition.ConditionalOnWebApplication;
import org.springframework.boot.autoconfigure.condition.ConditionalOnWebApplication.Type;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.List;

@Configuration(proxyBeanMethods = false)
@ConditionalOnWebApplication(type = Type.SERVLET)
@AutoConfigureBefore(org.springframework.boot.autoconfigure.web.servlet.WebMvcAutoConfiguration.class)
public class CloudEventsWebMvcAutoConfiguration {

    @Configuration
    public static class CloudEventHandlerConfiguration implements WebMvcConfigurer {

        @Override
        public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
            converters.add(0, new CloudEventHttpMessageConverter());
        }

    }

    

}
