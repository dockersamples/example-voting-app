package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	dapr "github.com/dapr/go-sdk/client"
	"github.com/gofiber/fiber/v2"
)

var (
	STATESTORE_VOTES_NAME   = "statestore"
	STATESTORE_RESULTS_NAME = "results"
)

type Post struct {
	Results []Data `json:"results"`
}

type Data struct {
	Vote Vote `json:"data"`
}

type Vote struct {
	Option  string `json:"option"`
	Type    string `json:"type"`
	VoterId string `json:"voterId"`
}

type Results struct {
	OptionA int `json:"optionA"`
	OptionB int `json:"optionB"`
}

func query() {
	for {
		time.Sleep(2 * time.Second)
		// HTTP endpoint
		queryurl := "http://localhost:3500/v1.0-alpha1/state/" + STATESTORE_VOTES_NAME + "/query?metadata.contentType=application/json&metadata.queryIndexName=voteIndex"

		// JSON body
		body := []byte(`{
			"filter": {
				"EQ": { "type": "vote" }
			},
			"sort": [
				{
					"key": "type",
					"order": "DESC"
				}
			]
		}`)

		// Create a HTTP post request
		r, err := http.NewRequest("POST", queryurl, bytes.NewBuffer(body))
		r.Header.Add("Content-Type", "application/json")
		r.Header.Add("dapr-app-id", "worker	")
		if err != nil {
			log.Printf("An error occured creating the request: %v", err)
		}

		client := &http.Client{}
		res, err := client.Do(r)
		if err != nil {
			log.Printf("An error sending request: %v", err)
		}

		post := &Post{}
		derr := json.NewDecoder(res.Body).Decode(post)
		if derr != nil {
			log.Printf("An error decoding the body: %v", err)
		}

		defer res.Body.Close()

		fmt.Println("Code", res.StatusCode)
		fmt.Println("Body:", post)

		var optionACount = 0
		var optionBCount = 0
		for _, r := range post.Results {
			fmt.Println("Option:", r.Vote.Option)
			if r.Vote.Option == "a" {
				optionACount = optionACount + 1
			} else if r.Vote.Option == "b" {
				optionBCount = optionBCount + 1
			}

		}

		results := &Results{
			OptionA: optionACount,
			OptionB: optionBCount,
		}

		jsonDataResult, err := json.Marshal(results)
		if err != nil {
			log.Printf("An error occured while marshalling results to json: %v", err)
		}

		ctx := context.Background()

		daprClient, err := dapr.NewClient()
		if err != nil {
			panic(err)
		}

		err = daprClient.SaveState(ctx, STATESTORE_VOTES_NAME, "results", jsonDataResult, map[string]string{
			"contentType": "application/json",
		})
		if err != nil {
			log.Printf("An error occured while storing the vote: %v", err)
		}

	}

}

func main() {

	app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	go query()

	log.Fatal(app.Listen(":3000"))

}
