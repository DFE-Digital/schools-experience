# Environment Variables

The school experience application supports various environment variables
to control different aspects of the application.

These can be configured as part of your shell or more easily by editing the 
`.env` file. Optionally `.env.development / `.env.test` files can be created for
environment specific variables. 

Full documentation is at 
[https://github.com/bkeepers/dotenv/blob/master/README.md](https://github.com/bkeepers/dotenv/blob/master/README.md)

## HTTP Basic Auth access control

If its required to password protect then entire application then you can set two
environment variables when booting the app. This can either be part of the 
deployment configuration.

```
SECURE_USERNAME = <my-username>
SECURE_PASSWORD = <my-password>
```

## Exception notification

If required Exceptions Notifications can be sent to a Slack channel. This is 
enabled and configured via environment variables.

`SLACK_WEBHOOK` _(required)_ Webhook to use to post to Slack

`SLACK_CHANNEL` _(optional)_ Channel to post to, should be left blank if hook defaults to a specifi channel

`SLACK_ENV` _(optional)_ Identifier for deployment environment - eg Staging or Production



