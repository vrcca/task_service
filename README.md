# Task Service

**Generates tasks based on tasks dependencies.**


## Installation
1. Install Erlang 20.0 or later
2. Install Elixir 1.9+
3. Run `make`

## Running the tests
In the root folder, run `make test`

## Running the app locally
Run `make run`


## Manual testing

In the `priv/` folder there are json files to that you can use to run a few scenarios. You can change the `Accept` header to `application/json` or omit it to receive a JSON response.

Here are the commands that you can use for the scenarios:

1. Successful bash plan from task json
```
curl -H "Content-Type: application/json" -H "Accept: text/plain" -d @sucessful_tasks.json  http://localhost:4001/plans
```

2. Cyclic dependency error
```
curl -H "Content-Type: application/json" -H "Accept: text/plain" -d @invalid_tasks.json  http://localhost:4001/plans
```
