package main

import "main/dagger"

type Voteapp struct{}

// example usage: "dagger call vote-app --dir . up"
func (m *Voteapp) VoteApp(dir *Directory) *Service {
	redisSvc := dag.Container().
		From("redis/redis-stack").
		WithExposedPort(6379).AsService()

	voteSvc := dag.Vote().
		Run(dir.Directory("java/vote"), dagger.VoteRunOpts{
			Redis:         redisSvc,
			ComponentsDir: dir.Directory("java/vote/components"),
		})

	resultSvc := dag.Result().Run(dir.Directory("go/result"))

	return dag.Proxy().
		WithService(voteSvc, "vote", 8080, 8080).
		WithService(resultSvc, "result", 3000, 3000).
		Service()
}
