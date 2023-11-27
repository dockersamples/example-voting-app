resource "docker_image" "seed_data" {
  count = var.seed ? 1 : 0
  name  = "seed-data"
  build {
    context = "./seed-data"
  }
}

resource "docker_container" "seed" {
  count = var.seed ? 1 : 0

  name  = "seed"
  image = docker_image.seed_data[0].image_id
  depends_on = [
    docker_container.vote,
  ]
  networks_advanced {
    name = docker_network.front_tier.id
  }
  restart = "no"
}
