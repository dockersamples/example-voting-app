package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"time"

	dapr "github.com/dapr/go-sdk/client"
	"github.com/gin-gonic/gin"
	socketio "github.com/googollee/go-socket.io"
)

var (
	STATESTORE_RESULTS_NAME = "results-statestore"
)
var conns = []socketio.Conn{}

type Data struct {
	OptionA int `json:"optionA"`
	OptionB int `json:"optionB"`
}

type Result struct {
	Data Data `json:"data"`
}

type Score struct {
	A string `json:"a"`
	B string `json:"b"`
}

func main() {

	router := gin.New()

	server := socketio.NewServer(nil)

	server.OnConnect("/", func(s socketio.Conn) error {
		s.SetContext("")
		log.Println("connected:", s.ID())

		conns = append(conns, s)

		return nil
	})

	server.OnError("/", func(s socketio.Conn, e error) {
		log.Println("on error:", e)
	})

	server.OnDisconnect("/", func(s socketio.Conn, msg string) {
		log.Println("closed", msg)
	})

	go func() {
		if err := server.Serve(); err != nil {
			log.Fatalf("socketio listen error: %s\n", err)
		}
	}()
	defer server.Close()

	router.StaticFile("/css/style.css", "static/css/style.css")
	router.StaticFile("/app.js", "static/app.js")
	router.StaticFile("/socket.io.js", "static/socket.io.js")
	router.StaticFile("/angular.min.js", "static/angular.min.js")
	router.StaticFile("/", "static/index.html")

	router.GET("/socket.io/*any", gin.WrapH(server))
	router.POST("/socket.io/*any", gin.WrapH(server))

	go getVotes()

	if err := router.Run(":3000"); err != nil {
		log.Fatal("failed run app: ", err)
	}

}

func getVotes() {
	daprClient, err := dapr.NewClient()
	ctx := context.Background()
	if err != nil {
		panic(err)
	}
	for {
		time.Sleep(1 * time.Second)
		log.Printf("Getting votes... ")
		resultsState, err := daprClient.GetState(ctx, STATESTORE_RESULTS_NAME, "results", nil)
		if err != nil {
			log.Printf("An error occured while getting the results: %v", err)
			continue
		}
		results := &Data{}

		log.Printf("Result: %s", resultsState.Value)

		err = json.Unmarshal(resultsState.Value, results)
		if err != nil {
			log.Printf("There was an error decoding the results into the struct: %v", err)
		}

		var score = &Score{
			A: fmt.Sprintf("%d", results.OptionA),
			B: fmt.Sprintf("%d", results.OptionB),
		}

		var jsonScore, _ = json.Marshal(score)

		log.Printf("JSON Score %s", jsonScore)

		for _, s := range conns {
			s.Emit("scores", string(jsonScore))
		}
	}

}
