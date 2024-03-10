package main

type Result struct{}

func (m *Result) Serve(
	dir *Directory,
	// +optional
	componentsPath *Directory,
	// +optional
	postgresSvc *Service,
) *Service {
	return m.Build(dir, componentsPath, postgresSvc).
		WithExposedPort(3000).
		AsService()
}

func (m *Result) Build(
	dir *Directory,
	// +optional
	componentsPath *Directory,
	// +optional
	postgresSvc *Service,
) *Container {
	if componentsPath == nil {
		componentsPath = dir.Directory("components")
	}

	dapr := dag.Dapr().Dapr("result", DaprDaprOpts{ComponentsPath: componentsPath})

	if postgresSvc != nil {
		dapr = dapr.WithServiceBinding("db", postgresSvc)
	}

	return dag.Go().WithSource(dir).Container().
		WithServiceBinding("dapr", dapr.AsService()).
		WithEnvVariable("DAPR_GRPC_ENDPOINT", "dapr").
		WithEntrypoint([]string{"go", "run", "main.go"})
}
