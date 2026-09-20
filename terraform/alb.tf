# Application Load Balancer using AWS Community Module
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name                       = "${var.app_name}-alb"
  vpc_id                     = local.vpc_id
  subnets                    = local.public_subnet_ids
  enable_deletion_protection = false

  # Security Group rules
  security_group_ingress_rules = {
    http_80 = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP traffic for redirect to HTTPS"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https_443 = {
      from_port   = 80
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS secure web traffic for Vote and Result apps"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https_8443 = {
      from_port   = 8443
      to_port     = 8443
      ip_protocol = "tcp"
      description = "HTTPS secondary port for Result app"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  # Listeners configuration
  listeners = {
    # 1. Port 80 HTTP -> Redirect to HTTPS 443
    http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    # 2. Port 443 HTTPS Listener with Host-based Routing
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
      forward = {
        target_group_key = "vote"
      }
      rules = {
        vote_host = {
          actions = [{
            type             = "forward"
            target_group_key = "vote"
          }]
          conditions = [{
            host_header = {
              values = ["${var.vote_subdomain}.${var.domain_name}"]
            }
          }]
        }
        result_host = {
          actions = [{
            type             = "forward"
            target_group_key = "result"
          }]
          conditions = [{
            host_header = {
              values = ["${var.result_subdomain}.${var.domain_name}"]
            }
          }]
        }
      }
    }

    # 3. Port 8443 HTTPS Listener directly for Result App
    result_https = {
      port            = 8443
      protocol        = "HTTPS"
      certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
      forward = {
        target_group_key = "result"
      }
    }
  }

  target_groups = {
    vote = {
      name_prefix       = "vote-"
      protocol          = "HTTP"
      port              = 80
      target_type       = "ip"
      create_attachment = false
      health_check = {
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 15
        path                = "/"
        matcher             = "200-399"
      }
    }
    result = {
      name_prefix       = "rslt-"
      protocol          = "HTTP"
      port              = 80
      target_type       = "ip"
      create_attachment = false
      health_check = {
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 15
        path                = "/"
        matcher             = "200-399"
      }
    }
  }

  tags = {
    Name = "${var.app_name}-alb"
  }
}
