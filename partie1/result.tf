resource "docker_image" "result" {
  name = "result"
  build {
    context = "./result"
  }
}

resource "docker_container" "result" {
  name  = "result"
  image = docker_image.result.image_id
  depends_on = [
    docker_container.db,
  ]
  networks_advanced {
    name = docker_network.front_tier.id
  }
  networks_advanced {
    name = docker_network.back_tier.id
  }

  entrypoint = ["nodemon", "--inspect=0.0.0.0", "server.js"]

  volumes {
    host_path      = "${abspath(path.root)}/result"
    container_path = "/usr/local/app"
  }

  ports {
    internal = 80
    external = 5001
  }

  ports {
    internal = 9229
    external = 9229
    ip       = "127.0.0.1"
  }
}
