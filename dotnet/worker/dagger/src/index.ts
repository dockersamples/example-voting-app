import { dag, Directory, object, func, Container } from "@dagger.io/dagger";

@object()
// eslint-disable-next-line @typescript-eslint/no-unused-vars
class Worker {
  @func()
  run(directoryArg: Directory, componentsDir: Directory = null): Container {
    const redis = dag
      .container()
      .from("redis/redis-stack")
      .withExposedPort(6379)
      .asService();

    const dapr = dag
      .dapr()
      .dapr("worker", { componentsPath: componentsDir })
      .withServiceBinding("redis", redis)
      .withExposedPort(3500)
      .asService();

    const build = dag
      .container()
      .from("mcr.microsoft.com/dotnet/sdk:7.0")
      .withMountedDirectory("/source", directoryArg.withoutDirectory("dagger"))
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
      .withWorkdir("/app")
      .withExec(["dotnet", "Worker.dll"]);
  }
}
