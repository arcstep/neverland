# Neverland

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

# 网站配置

## Nginx配置

编辑配置文件 `sudo nano /etc/nginx/sites-available/default`：

```
server {
  listen 80;
  server_name localhost;
  root /var/www/html;

  index index.html index.htm;

  location / {
    try_files $uri$uri/ =404;
  }
}
```

启动 Nginx 服务 `sudo systemctl restart nginx`。