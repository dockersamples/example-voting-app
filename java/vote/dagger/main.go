package main

type Vote struct{}

func (m *Vote) Run(
	dir *Directory,
	// +optional
	componentsPath *Directory,
) *Service {
	// dapr := dag.Dapr().Dapr("result", DaprDaprOpts{ComponentsPath: componentsPath})

	return dag.Container().From("maven:3.8.5-openjdk-17").
		WithMountedCache("/root/.m2", dag.CacheVolume("m2_cache")).
		WithMountedDirectory("/app", dir).
		WithWorkdir("/app").
		WithExposedPort(8080).
		WithExec([]string{"mvn", "spring-boot:run"}).
		AsService()
}
