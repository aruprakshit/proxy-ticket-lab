# Forward proxy vs reverse proxy: a Ruby homelab

Learn to explain **where an HTTP request went and why it succeeded or failed** by building a small ticket service, adding proxies, and testing failures.

**[Run the first experiment: direct-access baseline](lessons/01-direct-access.md)**

**Available now:** Sinatra + Puma + curl. Proxy experiments are planned.

Imagine you run a website that sells tickets for **Ruby Night**. We'll use it to explore two situations.

## Situation 1: you operate the ticket website

Initially, customers connect straight to your Ruby application:

```text
Customer → Ruby ticket application
```

Later, you want to run two copies of the application, or replace one during a deployment. Customers should still use the same address, such as `tickets.example.com`.

You place a **reverse proxy** at that address:

```text
                         → Ruby application A
Customer → Reverse proxy
                         → Ruby application B
```

The customer uses the ticket website's address; they don't select a backend or configure a proxy in their client. The reverse proxy receives the request and forwards it to a backend application.

**A stable entrance means the customer-facing address stays the same while the applications behind it can change.** It does not automatically guarantee uninterrupted service—we'll test failures later.

## Situation 2: you operate a company's employee network

Now imagine someone at work wants to visit the ticket website. Their company allows access to an approved ticket provider but blocks other ticket sites.

The company can configure the employee's client to send requests through a **forward proxy**:

```text
Employee's client → Company forward proxy → Ticket website
```

In the planned forward-proxy experiment, the client will be explicitly configured to use the company proxy while still requesting the ticket website. The forward proxy checks that destination, then allows or refuses the request.

Here, the company manages **the client's access to websites**. It doesn't operate those websites. Simply configuring a proxy does not prevent clients from bypassing it; we'll explore that distinction in a later experiment.

| Question | Forward proxy | Reverse proxy |
| --- | --- | --- |
| In our story, who runs it? | The employee's company | The ticket website operator |
| What does it handle? | The client's requests to destinations | Incoming requests to the ticket service |
| What does the client address? | The destination website, using a configured proxy. | The ticket website's address, served by the proxy. |

**The roles are what distinguish them:** a forward proxy acts on behalf of clients; a reverse proxy receives requests on behalf of servers. Filtering and load balancing are capabilities—a forward proxy need not block destinations, and a reverse proxy can serve a single backend.

## How to use this lab

The initial experiments use plain HTTP. The forward-proxy lessons will use explicit client configuration; HTTPS and transparent proxying are outside this sequence.

Start before either proxy exists:

```text
curl client container → Sinatra ticket application, served by Puma
```

The app returns a fixed ticket listing, identifies the backend, and logs a request marker. There is no database or booking state. This gives us a request we can trace before adding a reverse proxy. The employee-network situation comes later, with the forward proxy.

Predict first, run the commands, then compare your response and logs with the lesson. Each lesson includes recovery steps, references its source commit, and distinguishes expected output from observed results.

### Prerequisites

- Basic Docker and Ruby knowledge.
- Ubuntu WSL with Docker Desktop running and WSL integration enabled.
- Docker Compose and Git.
- Internet access for the first build.

Run commands in WSL Bash from the repository directory. Ruby, gems, and the HTTP client stay in containers.

## Reading order

**Available**

1. [Direct-access baseline](lessons/01-direct-access.md) — can we match a successful client response to its application log? Source checkpoint: `7b8ee29`; no proxies are configured.

**Planned**

2. **Reverse proxy:** How does Nginx give the client one entrance to the Sinatra service?
3. **Backend failure:** Can the proxy be reachable while the application is unavailable?
4. **Two backends:** Can one client-facing address reach different application instances?
5. **Forward proxy:** What changes when the client explicitly sends its requests through Squid?
6. **Destination policy:** Can Squid allow one lab destination and deny another?
7. **Bypass:** Does configuring a proxy actually enforce its access policy?
8. **Both proxies:** Can we trace one request through Squid, Nginx, and Sinatra?
