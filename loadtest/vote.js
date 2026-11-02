// k6 load test for the vote service.
// Pass/fail thresholds are the SLOs, so a red k6 run means "this release
// would burn error budget", not just "it felt slow".
//
//   PROFILE=smoke  quick CI gate       (5 VUs, 30 s)
//   PROFILE=load   expected peak       (ramp to 50 VUs, ~4 min)
//   PROFILE=spike  sudden 4x surge     (10 -> 200 VUs)
//   PROFILE=steady constant load used during chaos experiments
import http from "k6/http";
import { check, sleep } from "k6";
import { Rate } from "k6/metrics";

const BASE_URL = __ENV.BASE_URL || "http://localhost:5000";
const PROFILE = __ENV.PROFILE || "smoke";
const DURATION = __ENV.DURATION || "90s";
const RATE = parseInt(__ENV.RATE || "50", 10);

const profiles = {
  smoke: { executor: "constant-vus", vus: 5, duration: "30s" },
  load: {
    executor: "ramping-vus",
    startVUs: 0,
    stages: [
      { duration: "30s", target: 20 },
      { duration: "1m", target: 50 },
      { duration: "2m", target: 50 },
      { duration: "30s", target: 0 },
    ],
  },
  spike: {
    executor: "ramping-vus",
    startVUs: 10,
    stages: [
      { duration: "30s", target: 10 },
      { duration: "10s", target: 200 },
      { duration: "1m", target: 200 },
      { duration: "10s", target: 10 },
      { duration: "30s", target: 10 },
    ],
  },
  steady: {
    executor: "constant-arrival-rate",
    rate: RATE, timeUnit: "1s", duration: DURATION,
    preAllocatedVUs: 20, maxVUs: 100,
  },
};

const voteFailed = new Rate("vote_failed");

export const options = {
  // k6 resets cookies every iteration, so each iteration is a new voter
  // and every accepted vote should become exactly one row in Postgres.
  scenarios: { [PROFILE]: profiles[PROFILE] },
  thresholds: {
    // Availability SLO: 99.5% success
    http_req_failed: [{ threshold: "rate<0.005", abortOnFail: false }],
    // Latency SLO: 99% under 300 ms (p95 tracked too for the report)
    http_req_duration: ["p(99)<300", "p(95)<200"],
    vote_failed: ["rate<0.005"],
  },
  summaryTrendStats: ["avg", "med", "p(95)", "p(99)", "max"],
};

export default function () {
  // 1 page view, then a vote: roughly what a real user does.
  const page = http.get(`${BASE_URL}/`, { tags: { name: "GET /" } });
  check(page, { "page 200": (r) => r.status === 200 });

  const option = Math.random() < 0.5 ? "a" : "b";
  const res = http.post(`${BASE_URL}/`, { vote: option }, { tags: { name: "POST / (vote)" } });
  const ok = check(res, { "vote accepted": (r) => r.status === 200 });
  voteFailed.add(!ok);

  if (PROFILE !== "steady") sleep(Math.random() * 1 + 0.5);
}

export function handleSummary(data) {
  const out = `/results/k6-${__ENV.RUN_NAME || PROFILE}-summary.json`;
  return { stdout: textSummary(data), [out]: JSON.stringify(data, null, 2) };
}

function textSummary(data) {
  const m = data.metrics;
  const pct = (v) => (v * 100).toFixed(3) + "%";
  const lines = [
    `\n=== k6 ${PROFILE} ===`,
    `requests:        ${m.http_reqs.values.count} (${m.http_reqs.values.rate.toFixed(1)}/s)`,
    `failed:          ${pct(m.http_req_failed.values.rate)}  (SLO < 0.5%)`,
    `latency p95/p99: ${m.http_req_duration.values["p(95)"].toFixed(1)} / ${m.http_req_duration.values["p(99)"].toFixed(1)} ms  (SLO p99 < 300 ms)`,
  ];
  for (const [name, t] of Object.entries(data.metrics)) {
    if (t.thresholds) for (const [expr, r] of Object.entries(t.thresholds))
      lines.push(`  ${r.ok ? "PASS" : "FAIL"}  ${name} ${expr}`);
  }
  return lines.join("\n") + "\n";
}
