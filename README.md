# Kukotbot

WIP Telegram chatbot

Start iex interactive shell, without starting any applications:

```bash
iex -S mix run --no-start
```

If you need some parts of the program, you need to start them explicitly.
Eg to start using HTTPoison to make requests:
```bash
iex(3)> Application.ensure_all_started(:httpoison)
{:ok,
 [:unicode_util_compat, :idna, :mimerl, :certifi, :ssl_verify_fun, :metrics,
  :hackney, :httpoison]}
iex(2)> HTTPoison.get!("https://www.google.fi")
%HTTPoison.Response{
  # ... rest of the response...
```

Running without `--no-start` will start the bot and it will start receiving messages:

```bash
iex -S mix
```

# Running

With mix:
```
 mix run --no-halt | tee kukotbot.log
 ```

# Docker

