package main

import "main/internal/dagger"

type Voteapp struct{}

// example usage: "dagger call vote-app --dir . up"
func (m *Voteapp) VoteApp(dir *Directory) *Service {
	redisSvc := dag.Container().
		From("redis/redis-stack").
		WithExposedPort(6379).AsService()

	postgresSvc := dag.Container().
		From("postgres:15-alpine").
		WithEnvVariable("POSTGRES_PASSWORD", "postgres").
		WithExposedPort(5432).AsService()

	voteSvc := dag.Vote().
		Serve(dir.Directory("java/vote"), dagger.VoteServeOpts{
			Redis:         redisSvc,
			ComponentsDir: dir.Directory("java/vote/components"),
		})

	resultSvc := dag.Result().
		Serve(dir.Directory("go/result"), dagger.ResultServeOpts{
			ComponentsPath: dag.Directory().WithFile("results-statestore.yaml", dir.Directory("k8s-dapr").File("results-statestore.yaml")),
			PostgresSvc:    postgresSvc,
		})

	workerSvc := dag.Worker().
		Serve(dir.Directory("dotnet/worker"),
			dagger.WorkerServeOpts{
				RedisSvc:       redisSvc,
				PostgresSvc:    postgresSvc,
				ComponentsPath: dir.Directory("k8s-dapr"),
			},
		)

	return dag.Proxy().
		WithService(voteSvc, "vote", 8080, 8080).
		WithService(resultSvc, "result", 3000, 3000).
		WithService(workerSvc, "worker", 3001, 3001).
		Service()
}
