import Config

config :task_service, port: System.fetch_env!("PORT")
