# domains
## Create a domain server
1. Run `localStorage.setItem("domainservice", true);` in browser console
2. Copy `.env.template`, create a file called `.env.secret`, fill in registration credential copied from console
3. Run `docker-compose up domain-server`
4. Change `DS_OPERATION_MODE` to `private` if you want to set up a private server instead
