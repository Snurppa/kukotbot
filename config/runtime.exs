import Config

config :kukotbot,
  env_test: System.get_env("KUKOTBOT_TEST_VAR"),
  bot_api_key: System.get_env("KUKOTBOT_API_KEY"),
  cowboy_port: (System.get_env("KUKOTBOT_HTTP_PORT") || "8080") |> String.to_integer

config :logger,
  level: (System.get_env("LOG_LEVEL") || "info")
         |> String.to_existing_atom
