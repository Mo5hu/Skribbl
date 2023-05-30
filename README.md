# skribbl-clone

This project is an inspiration from Skribbl.io on Web submitted as a Mobile App Version of it.

<h3>Frontend</h3>

Go to <code>./skribbl/lib/uri/server_address.dart</code> 
It has two environment variables which require Server URI address.

This project also uses socket.io show it will show the realtime update of the drawing, score and words.

<h3>Backend</h3>

To set Environment variables, check <code>./server/.env.example</code>

To Setup <code>CONNECTION_STRING</code>, You need to create a MongoDB host, consider using MongoDB Atlas. Atlas is a cloud-hosted database-as-a-service which requires no installation, offers a free tier to get started, and provides a copyable URI to easily connect Compass to your deployment.
Also check: https://www.mongodb.com/docs/compass/current/connect/

To Setup <code>PRIVATE_KEY, PROJECT_ID, and CLIENT_EMAIL</code> generate a private key for firebase SDK, and enter fields in use.
Also check: https://firebase.google.com/docs/admin/setup#:~:text=In%20the%20Firebase%20console%2C%20open,confirm%20by%20clicking%20Generate%20Key.

rename <code>.env.example</code> to <code>.env</code>

First run <code>npm i</code> to install the node module dependencies.

To start run

<code>npm run start</code>

## Deployment
#### Mongodb Deployment:
There are two ways we can deploy and consume MongoDB server:
 - Service: We can use MongoDB Atlas, it comes with prebuilt security and is easy get start with
 - PaaS: Deploy a MongoDB instance on a server and configure it manually, its difficult and time consuming

For MongoDB atlas, you just need to create an account, initiate a. cluster and create a user to login.
You will also need to either whitelist an IP address of the server or Allow all origin. Once all of this is configured you can then get the connection string that your server consumes.

#### Server Deployment:
 - Choose PaaS of your choice, Heroku and DigitalOcean are a good choice.
 - They provide high availability servers with easy configurations
For Digital Ocean:
 - create an account.
 - configure a droplet
 - connect your Github Repo
 - give start script
 - configure environment variables
 - and run the droplet.
