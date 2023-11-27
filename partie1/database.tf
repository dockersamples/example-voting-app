resource "docker_image" "postgres_alpine" {
  name         = "docker.io/postgres:15-alpine"
  keep_locally = true
}

resource "docker_container" "db" {
  name  = "db"
  image = docker_image.postgres_alpine.image_id
  networks_advanced {
    name = docker_network.back_tier.id
  }

  healthcheck {
    test         = ["healthchecks/postgres.sh"]
    interval     = "5s"
    start_period = "10s"
  }

  env = [
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=postgres",
  ]


  volumes {
    host_path      = "/db-data"
    container_path = "/var/lib/postgresql/data"
  }

  volumes {
    host_path      = "/healthchecks"
    container_path = "/healthchecks"
  }
}
