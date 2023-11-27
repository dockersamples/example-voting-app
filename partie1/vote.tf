resource "docker_image" "vote_dev" {
  name = "vote"
  build {
    context = "./vote"
    target  = "dev"
  }
}

resource "docker_container" "vote" {
  name  = "vote"
  image = docker_image.vote_dev.image_id
  depends_on = [
    docker_container.redis,
  ]
  networks_advanced {
    name = docker_network.front_tier.id
  }
  networks_advanced {
    name = docker_network.back_tier.id
  }

  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }

  volumes {
    host_path      = "${abspath(path.root)}/vote"
    container_path = "/usr/local/app"
  }

  ports {
    internal = 80
    external = 5000
  }
}
