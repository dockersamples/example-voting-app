package main

type Result struct{}

func (m *Result) Run(
	dir *Directory,
	// +optional
	componentsPath *Directory,
) *Service {
	dapr := dag.Dapr().Dapr("result", DaprDaprOpts{ComponentsPath: componentsPath})

	return dag.Go().WithSource(dir).Container().
		WithServiceBinding("dapr", dapr.AsService()).
		WithEnvVariable("DAPR_GRPC_ENDPOINT", "dapr").
		WithExec([]string{"go", "run", "main.go"}).
		WithExposedPort(3000).
		AsService()
}
