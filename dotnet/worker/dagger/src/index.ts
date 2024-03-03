import {
  dag,
  Directory,
  object,
  func,
  Service,
  Container,
} from "@dagger.io/dagger";

@object()
// eslint-disable-next-line @typescript-eslint/no-unused-vars
class Worker {
  @func()
  run(
    dir: Directory,
    redisSvc?: Service,
    postgresSvc?: Service,
    componentsPath?: Directory,
  ): Service {
    return this.container(dir, redisSvc, postgresSvc, componentsPath)
      .withExec(["dotnet", "Worker.dll"])
      .asService();
  }

  @func()
  container(
    dir: Directory,
    redisSvc?: Service,
    postgresSvc?: Service,
    componentsPath?: Directory,
  ): Container {
    if (!componentsPath) {
      componentsPath = dir.directory("components");
    }

    if (!redisSvc) {
      redisSvc = dag
        .container()
        .from("redis/redis-stack")
        .withExposedPort(6379)
        .asService();
    }

    if (!postgresSvc) {
      postgresSvc = dag
        .container()
        .from("postgres:15-alpine")
        .withEnvVariable("POSTGRES_PASSWORD", "postgres")
        .withExposedPort(5432)
        .asService();
    }
    const dapr = dag
      .dapr()
      .dapr("worker", { componentsPath: componentsPath })
      .withServiceBinding("redis", redisSvc)
      .withServiceBinding("db", postgresSvc)
      .withExposedPort(50001)
      .asService();

    const build = dag
      .container()
      .from("mcr.microsoft.com/dotnet/sdk:7.0")
      .withMountedDirectory("/source", dir.withoutDirectory("dagger"))
      .withWorkdir("/source")
      .withExec(["dotnet", "restore"])
      .withExec([
        "dotnet",
        "publish",
        "-c",
        "release",
        "-o",
        "/app",
        "--self-contained",
        "false",
        "--no-restore",
      ]);

    return dag
      .container()
      .from("mcr.microsoft.com/dotnet/aspnet:7.0")
      .withMountedDirectory("/app", build.directory("/app"))
      .withServiceBinding("dapr", dapr)
      .withEnvVariable("DAPR_GRPC_ENDPOINT", "http://dapr:50001")
      .withEnvVariable("BASE_URL", "http://dapr")
      .withWorkdir("/app");
  }
}
