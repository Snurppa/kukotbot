import Config

config :kukotbot,
  env_test: System.get_env("KUKOTBOT_TEST_VAR"),
  bot_api_key: System.get_env("KUKOTBOT_API_KEY")

config :logger,
  level: System.get_env("LOG_LEVEL") || :info
