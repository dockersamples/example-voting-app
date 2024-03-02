using System;
using System.Data.Common;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using Dapr.Client;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Worker
{
    public record Results([property: JsonPropertyName("optionA")] int optionA, [property: JsonPropertyName("optionB")] int optionB);
    public record Post([property: JsonPropertyName("results")] Data[] results);
    public record Data([property: JsonPropertyName("data")] Vote vote);
    public record Vote([property: JsonPropertyName("option")] string option, [property: JsonPropertyName("type")] string type, [property: JsonPropertyName("voterId")] string voterId);

    public class Program
    {
        public static async Task<int> Main(string[] args)
        {
            var VOTES_STATE_STORE = "votes-statestore";
            var RESULTS_STATE_STORE = "results-statestore";
            var httpClient = new HttpClient();
            httpClient.DefaultRequestHeaders.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
            httpClient.DefaultRequestHeaders.Add("dapr-app-id", "worker");
            var daprClient = new DaprClientBuilder().Build();
            var baseURL = (Environment.GetEnvironmentVariable("BASE_URL") ?? "http://localhost") + ":" + (Environment.GetEnvironmentVariable("DAPR_HTTP_PORT") ?? "3500");
            try
            {

                var definition = new { vote = "", voter_id = "" };
                while (true)
                {
                    Console.WriteLine("Fetching the votes...");
                    // Slow down to prevent CPU spike, only query each 1000ms
                    Thread.Sleep(1000);

                    var filterJson = JsonSerializer.Serialize(
                                            new
                                            {
                                                filter = new
                                                {
                                                    EQ = new
                                                    {
                                                        type = "vote",
                                                    }
                                                },
                                                sort = new[] {
                                                    new {
                                                        key = "type",
                                                        order = "DESC"
                                                    },
                                                }
                                            });

                    Console.WriteLine("Filter JSON: " + filterJson);

                    var filters = new StringContent(filterJson, Encoding.UTF8, "application/json");

                    // Query state store for Votes
                    var response = await httpClient.PostAsync($"{baseURL}/v1.0-alpha1/state/{VOTES_STATE_STORE}/query?metadata.contentType=application/json&metadata.queryIndexName=voteIndex", filters);

                    Console.WriteLine("StatusCode: " + response.StatusCode);
                    

                    if (response.IsSuccessStatusCode)
                    {
                        var contents = await response.Content.ReadAsStringAsync();
                        Console.WriteLine("Response: " + contents);
                        Post? queryData = JsonSerializer.Deserialize<Post>(contents);

                        var optionACount = 0;
                        var optionBCount = 0;
                        foreach (Data data in queryData.results)
                        {
                            if (data.vote.option == "a")
                            {
                                optionACount = optionACount + 1;
                            }
                            if (data.vote.option == "b")
                            {
                                optionBCount = optionBCount + 1;
                            }
                        }

                        var results = new Results(optionACount, optionBCount);

                        // Save state into the state store
                        daprClient.SaveStateAsync(RESULTS_STATE_STORE, "results", results);
                    }
                    else
                    {
                        Console.WriteLine("ReasonPhrase: " + response.ReasonPhrase  );
                        var contents = await response.Content.ReadAsStringAsync();
                        Console.WriteLine("Response: " + contents);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine(ex.ToString());
                return -1;
            }
        }

    }
}