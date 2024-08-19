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


# 启动服务

```
nohup mix phx.server &
```

配置Nginx 配置文件 `sudo vi /etc/nginx/sites-available/illusky.com`：
```ini
server {
    listen 80;
    server_name www.illusky.com illusky.com;

    location / {
        proxy_pass http://localhost:4000;  # Phoenix 应用监听的地址
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Optional: Redirect HTTP to HTTPS
    listen [::]:80 ipv6only=on;
    if ($scheme = "http") {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name www.illusky.com illusky.com;

    # SSL Certificates
    ssl_certificate /etc/nginx/ssl/illusky.com.crt;
    ssl_certificate_key /etc/nginx/ssl/illusky.com.key;

    # SSL Settings
    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout 10m;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://localhost:4000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

**创建符号链接**

如果你创建了一个新的配置文件，需要创建一个符号链接到 sites-enabled 目录：

```bash
sudo ln -s /etc/nginx/sites-available/illusky.com /etc/nginx/sites-enabled/
```

**测试 Nginx 配置**

在修改配置文件之后，测试 Nginx 的配置是否正确：

```
bash
sudo nginx -t
```

如果配置正确，你会看到类似如下的输出：

```
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

**重启 Nginx**

如果配置测试成功，重启 Nginx 使更改生效：
```
sudo service nginx restart
```

**配置 SSL/TLS 证书**

如果你想要使用 HTTPS，你需要获取 SSL/TLS 证书。你可以使用 Let's Encrypt 之类的免费证书服务来获取证书。如果你已经有了证书文件，确保将它们放置在正确的目录，并在 Nginx 配置文件中引用它们。

**测试访问**
现在，你应该可以通过访问 www.illusky.com 来访问你的 Phoenix 应用了。如果一切正常，你会看到 Phoenix 应用的页面。

**注意事项**
确保 Phoenix 应用正在运行，并且监听在 4000 端口上。
如果你使用的是 HTTPS，确保你已经正确配置了 SSL/TLS 证书。
如果你有任何问题，可以查看 Nginx 的日志文件来诊断问题，通常位于 /var/log/nginx/access.log 和 /var/log/nginx/error.log。