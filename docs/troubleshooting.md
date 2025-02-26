# Troubleshooting

After launching the Domain Server, it's a good idea to take a look at the logs to make
sure your server is registered, working and accessible.
There are a few things you can look for:

- "successfully registered to DDS" should show up in the log.
- `"message":"responded","tags":{"agent":"Go-http-client/1.1","client_id":"","code":200,"ct_len_in":"","method":"GET","path":"/health",`
  should show up in the log. These are health checks running from the central
  Domain Discovery Service (DDS) to test that the server is up and running.
- Check that the server appears on Auki's posemesh
  [dashboard](https://dashboard.auki.network/servers)

If registration with DDS fails, check the status code in the log message.
The status code is the response from DDS when it tries to call your Domain Server.
Here are some common issues and solutions:

- `"message":"lookup postgres on 127.0.0.11:53: server misbehaving"` or
  `"message":"dial tcp: lookup postgres on 127.0.0.11:53: no such host"` usually means
  that the Domain Server can't reach the database. Check that the `postgres` container
  is running by using `docker ps` and check its logs with `docker compose logs --tail 100 postgres`
- `"failed parsing config from postgres connection string"` likely means that you have
  entered a password with special characters. The easiest solution is to use a password
  without special characters.
- `"500 Internal Server Error"` usually means that DDS couldn't reach your Domain Server
  because the connection to your configured URL failed or timed out. It could happen
  because you didn't do port forwarding in your router or didn't allow your web server
  / reverse proxy (such as nginx) or port 443 in your firewall. We have also seen cases
  where Internet Service Providers blocked common service ports like 80 and 443. Here's
  an example for [Orcon](https://help.orcon.net.nz/hc/en-us/articles/360005168154-Port-filtering-in-My-Orcon).
- You can test that your Domain Server is reachable from the public Internet using
  [reqbin.com](https://reqbin.com/). Write your Domain Server URL (the address you
  configured in the Docker Compose YAML file) and press the Send button. If you
  get a status 404 (Not Found) back with a body that says "route not found",
  everything is working as it should. If you don't, this is likely the reason for why
  your server fails to register with DDS.
- `409 Conflict` happens if you run two Domain Servers at the same time with the same
  wallet. Make sure you only run one Domain Server at a time with the same wallet.
