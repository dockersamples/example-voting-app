package main

type Vote struct{}

func (m *Vote) Build(
	dir *Directory,
	// +optional
	redis *Service,
	// +optional
	componentsDir *Directory,
) *Container {
	if redis == nil {
		redis = dag.Container().
			From("redis/redis-stack").
			WithExposedPort(6379).AsService()
	}

	if componentsDir == nil {
		componentsDir = dir.Directory("components")
	}

	dapr := dag.Dapr().
		Dapr("vote", DaprDaprOpts{ComponentsPath: componentsDir}).
		WithServiceBinding("redis", redis).
		WithExposedPort(50001)

	return dag.Container().From("maven:3.9.6-eclipse-temurin-21").
		WithServiceBinding("dapr", dapr.AsService()).
		WithEnvVariable("DAPR_GRPC_ENDPOINT", "http://dapr:50001").
		WithMountedCache("/root/.m2", dag.CacheVolume("m2_cache")).
		WithMountedDirectory("/app", dir).
		WithWorkdir("/app").
		WithExposedPort(8080).
		WithEntrypoint([]string{"mvn", "spring-boot:run"})
}

func (m *Vote) Serve(
	dir *Directory,
	// +optional
	redis *Service,
	// +optional
	componentsDir *Directory,
) *Service {
	return m.Build(dir, redis, componentsDir).
		WithExposedPort(8080).
		AsService()
}
