resource "docker_image" "redis_alpine" {
  name         = "docker.io/redis:alpine"
  keep_locally = true
}

resource "docker_container" "redis" {
  name  = "redis"
  image = docker_image.redis_alpine.image_id
  networks_advanced {
    name = docker_network.back_tier.id
  }

  healthcheck {
    test     = ["healthchecks/redis.sh"]
    interval = "5s"
  }

  volumes {
    host_path      = "/healthchecks"
    container_path = "/healthchecks"
  }
}
