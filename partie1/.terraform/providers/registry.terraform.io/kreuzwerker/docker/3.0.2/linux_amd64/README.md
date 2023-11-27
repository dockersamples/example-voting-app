<a href="https://docker.com">
    <img src="https://raw.githubusercontent.com/kreuzwerker/terraform-provider-docker/master/assets/docker-logo.png" alt="Docker logo" title="Docker" align="right" height="100" />
</a>
<a href="https://terraform.io">
    <img src="https://raw.githubusercontent.com/kreuzwerker/terraform-provider-docker/master/assets/terraform-logo.png" alt="Terraform logo" title="Terraform" align="right" height="100" />
</a>
<a href="https://kreuzwerker.de">
    <img src="https://raw.githubusercontent.com/kreuzwerker/terraform-provider-docker/master/assets/xw-logo.png" alt="Kreuzwerker logo" title="Kreuzwerker" align="right" height="100" />
</a>

# Terraform Provider for Docker

[![Release](https://img.shields.io/github/v/release/kreuzwerker/terraform-provider-docker)](https://github.com/kreuzwerker/terraform-provider-docker/releases)
[![Installs](https://img.shields.io/badge/dynamic/json?logo=terraform&label=installs&query=$.data.attributes.downloads&url=https%3A%2F%2Fregistry.terraform.io%2Fv2%2Fproviders%2F713)](https://registry.terraform.io/providers/kreuzwerker/docker)
[![Registry](https://img.shields.io/badge/registry-doc%40latest-lightgrey?logo=terraform)](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/kreuzwerker/terraform-provider-docker/blob/main/LICENSE)  
[![Go Status](https://github.com/kreuzwerker/terraform-provider-docker/workflows/Acc%20Tests/badge.svg)](https://github.com/kreuzwerker/terraform-provider-docker/actions)
[![Lint Status](https://github.com/kreuzwerker/terraform-provider-docker/workflows/golangci-lint/badge.svg)](https://github.com/kreuzwerker/terraform-provider-docker/actions)
[![Go Report Card](https://goreportcard.com/badge/github.com/kreuzwerker/terraform-provider-docker)](https://goreportcard.com/report/github.com/kreuzwerker/terraform-provider-docker)  

## Documentation

The documentation for the provider is available on the [Terraform Registry](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs).

Do you want to migrate from `v2.x` to `v3.x`? Please read the [migration guide](docs/v2_v3_migration.md)

## Example usage

Take a look at the examples in the [documentation](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs) of the registry
or use the following example:


```hcl
# Set the required provider and versions
terraform {
  required_providers {
    # We recommend pinning to the specific version of the Docker Provider you're using
    # since new versions are released frequently
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

# Configure the docker provider
provider "docker" {
}

# Create a docker image resource
# -> docker pull nginx:latest
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

# Create a docker container resource
# -> same as 'docker run --name nginx -p8080:80 -d nginx:latest'
resource "docker_container" "nginx" {
  name    = "nginx"
  image   = docker_image.nginx.image_id

  ports {
    external = 8080
    internal = 80
  }
}

# Or create a service resource
# -> same as 'docker service create -d -p 8081:80 --name nginx-service --replicas 2 nginx:latest'
resource "docker_service" "nginx_service" {
  name = "nginx-service"
  task_spec {
    container_spec {
      image = docker_image.nginx.repo_digest
    }
  }

  mode {
    replicated {
      replicas = 2
    }
  }

  endpoint_spec {
    ports {
      published_port = 8081
      target_port    = 80
    }
  }
}
```

## Building The Provider

[Go](https://golang.org/doc/install) 1.18.x (to build the provider plugin)


```sh
$ git clone git@github.com:kreuzwerker/terraform-provider-docker
$ make build
```

## Contributing

The Terraform Docker Provider is the work of many of contributors. We appreciate your help!

To contribute, please read the contribution guidelines: [Contributing to Terraform - Docker Provider](CONTRIBUTING.md)

## License

The Terraform Provider Docker is available to everyone under the terms of the Mozilla Public License Version 2.0. [Take a look the LICENSE file](LICENSE).


## Stargazers over time

[![Stargazers over time](https://starchart.cc/kreuzwerker/terraform-provider-docker.svg)](https://starchart.cc/kreuzwerker/terraform-provider-docker)
