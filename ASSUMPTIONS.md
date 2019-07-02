# ASSUMPTIONS

1. I am assuming the tasks and its dependencies will have a low number of tasks. This is due the problem not specifing the performance requirements, and to keep it simple.
2. There is no authentication required.
3. A simple API is enough. Therefore, I only used `Cowboy` for this.
4. I did not care about security issues such as DDoS, CORS, etc.
5. In order to keep the code simple, I avoided creating domain models and opted for keeping tasks as a map. If we are planning to increase the complexity, I suggest creating `Task` and `ExecutionPlan` model.


## About the API

I decided to call the endpoints as `/plans`, because you "create" an execution plan when you pass the tasks to `POST /plans`. Thus, returning the execution plan to the user.

The `/plans` endpoint decides the response type based on `accept`, otherwise returns json. Therefore, the bash script needs to pass `Accept: text/plain` as request header.


## Deployment

We should deploy this with a minimum of 2 instances, max 10. It should be behind a load balancer and API gateway.

A Dockerfile is provided with instructions on how to build the app for production. The port can be changed with the PORT environment variable.
