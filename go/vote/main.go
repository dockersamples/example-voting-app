package main

import (
	"context"
	"encoding/json"
	"log"
	"math/rand"
	"os"
	"time"

	dapr "github.com/dapr/go-sdk/client"
	fiber "github.com/gofiber/fiber/v2"
	html "github.com/gofiber/template/html/v2"
	"github.com/google/uuid"
)

var (
	STATESTORE_NAME = "statestore"
	hostname        = getHostname()
	option_a        = getEnv("OPTION_A", "Cats")
	option_b        = getEnv("OPTION_B", "Dogs")
)

type Vote struct {
	Type    string `json:"type"`
	VoterId string `json:"voterId"`
	Option  string `json:"option"`
}

func main() {

	engine := html.New("./templates", ".html")

	app := fiber.New(fiber.Config{
		Views: engine,
	})

	app.Static("/", "./static/")

	app.Post("/", serve)
	app.Get("/", serve)

	app.Listen(":3000")
}

func serve(c *fiber.Ctx) error {
	rand.Seed(time.Now().UnixMicro())
	voterId := c.Cookies("voter_id")
	if voterId == "" {
		voterId = uuid.New().String()[0:10]
	}

	vote := "None"

	if c.Method() == "POST" {
		vote = c.FormValue("vote")

		log.Printf("Got a vote from %s, %s", voterId, vote)
		daprClient, err := dapr.NewClient()
		if err != nil {
			panic(err)
		}

		ctx := context.Background()
		vote := &Vote{
			Type:    "vote",
			VoterId: voterId,
			Option:  vote,
		}

		jsonData, err := json.Marshal(vote)
		if err != nil {
			log.Printf("An error occured while marshalling vote to json: %v", err)
		}

		err = daprClient.SaveState(ctx, STATESTORE_NAME, "voter-"+voterId, jsonData, map[string]string{
			"contentType": "application/json",
		})
		if err != nil {
			log.Printf("An error occured while storing the vote: %v", err)
		}
	}

	return c.Render("index", fiber.Map{
		"option_a": option_a,
		"option_b": option_b,
		"hostname": hostname,
		"vote":     vote,
	})
}

// getEnv returns the value of an environment variable, or a fallback value if it is not set.
func getEnv(key, fallback string) string {
	value, exists := os.LookupEnv(key)
	if !exists {
		value = fallback
	}
	return value
}

func getHostname() string {
	hostname, err := os.Hostname()
	if err != nil {
		hostname = "N/A"
	}
	return hostname
}
