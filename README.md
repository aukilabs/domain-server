# domains
1. Create a domain server
`curl -XPOST https://dds.dev.aukiverse.com/api/v1/servers -H "Authorization: Bearer ${DDS_ACCESS_TOKEN}"`
2. Copy `.env.template`, create a file called `.env.secret`, fill in your server id and registration secret got from last step
3. Run `docker-compose up domain-server`
4. Change `DS_OPERATION_MODE` to `private` if you want to set up a private server instead
