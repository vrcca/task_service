# ASSUMPTIONS

1. I am assuming the tasks and its dependencies will have a low number of tasks. This is due the problem not specifing the performance requirements, and to keep it simple.
2. There is no authentication required.
3. A simple API is enough. Therefore, I only used `Cowboy` for this.
4. I did not care about security issues such as DDoS, CORS, etc.
5. In order to keep the code simple, I avoided creating domain models and opted for keeping tasks as a map. If we are planning to increase the complexity, I suggest creating `Task` and `ExecutionPlan` model.
