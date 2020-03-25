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

`SLACK_WEBHOOK` Webhook to use to post to Slack

`SLACK_CHANNEL` _(optional)_ Channel to post to, should be left blank if hook defaults to a specifi channel

`SLACK_ENV` _(optional)_ Identifier for deployment environment - eg Staging or Production

`SENTRY_DSN` Send exception reports to sentry, config value supplied by Sentry.

## Monitoring

`APP_INSIGHTS_INSTRUMENTATION_KEY` - value supplied by Microsoft Application Insights

## Gitis configuration

`FAKE_CRM` - use Fake CRM instead of a Dynamics instance, defaults to off in production, on in development. true = on, false = off, blank = default for environment

`CRM_CLIENT_ID` - Authentication ID for Active Directory tenant controlling access to Dynamics instance

`CRM_CLIENT_SECRET` - Authentication secret for Active Directory

`CRM_AUTH_TENANT_ID` - GUID for the Active Directory tenant

`CRM_SERVICE_URL` - URL for the Dynamics instance to be connected to

`CRM_PRIVACY_POLICY_ID` - GUID for the privacy policy used by candidates - supplied by Gitis team

`CRM_PRIVACY_CONSENT_ID` - GUID for the privacy policy consent id used by candidates - supplied by Gitis team

`CRM_CACHING` - Turn on caching of Contact details, cached for 1 hour into Redis - 1 = on, blank = off

`CRM_CHANNEL_CREATION` - GUID for the channel creation id, supplied by Gitis team

`CRM_COUNTRY_ID` - GUID for country to attach new Candidates to, supplied by Gitis team

`CRM_OWNER_ID` - GUID for owner of new Contacts, not currently used - supplied by Gitis team

## DFE Sign-in configuration

`DFE_SIGNIN_CLIENT_ID` - Client ID for OIDC integration with Sign-in

`DFE_SIGNIN_SECRET` - Client Secret for OIDC integration with Sign-in

`DFE_SIGNIN_BASE_URL` - URL for the site which DfE Sign-in OIDC flow will link back to

`DFE_SIGNIN_API_ENABLED` - Enhance the integration using the Sign-in API, also turns on check if the user belongs to multiple organisations, 1 = on, blank = off

`DFE_SIGNIN_API_ROLE_CHECK_ENABLED` - Enables checking the user supplied by DfE Sign-in has the appropriate role over the Organisation supplied by DfE Sign-in

`DFE_SIGNIN_API_SCHOOL_CHANGE_ENABLED` - Moves choosing an organisation from the Sign-in chooser to the the Change school screen within the app.

`DFE_SIGNIN_REQUEST_ORGANISATION_URL` - Shows a button on the Change school screen linking to DfE Sign-in request organisation functionality.

`DFE_SERVICES_LIST_URL` - Shows a link to the other services the user has access to within DfE Sign-in

`DFE_SIGNIN_SCHOOL_EXPERIENCE_ADMIN_SERVICE_ID` - UUID of the School experience service within the designated Sign-in environment, needed for the role check functionality

`DFE_SIGNIN_SCHOOL_EXPERIENCE_ADMIN_ROLE_ID` - UUID of the School experience administrator role within the designated Sign-in environment, needed for the role check functionality

## Other integrations

`NOTIFY_API_KEY` - API key used to send emails via Notify

`BING_MAPS_KEY` - API key used to query bing maps

`GA_TRACKING_ID` - Google Analytics API key

## Deactivating the service

`MAINTENANCE_MODE` - Put entire service into maintenance mode, 1 = on, blank = off

`DFE_SIGNIN_DEACTIVATED` - Disable sign-in, useful if their is a Sign-in outage - 1 = on, blank = off

`DEACTIVATE_CANDIDATES` - Deactivates candidate applications, including searching

`CANDIDATE_NOTIFICATION` - Shows a notification below to the 'Start now >' button on the home page. Variable content is formatted as paragraphs, \n\n = new paragraph, blank = off

`CANDIDATE_URN_WHITELIST` - Restrict candidate searches to a white list of schools, comma separated list of URNs, blank = off, -1 = on but no schools will match

`FEATURE_FLAGS` - Comma separated list of features to enable, appended to features listed in environment file

`PHASE` - Earlier iteration of feature flagging, currently used to disable candidate dashboard access.

## Database configuration

`DATABASE_URL` - normal rails variable

`DB_HOST` - postgres host, defaults to nil - ie, use socket

`DB_DATABASE` - name of database to use

`DB_USERNAME` - username for postgres

`DB_PASSWORD` - password for postgres

REDIS_URL - url for Redis server, defaults to local Redis server

## Redirection

`CANONICAL_DOMAIN` - if set, connections via a different domain are redirected to the canonical one

`OLD_SEP_DOMAINS` - comma separated list, if a connection is for a matching domain, than redirect to the 'Service has migrated' page on the canonical domain.

## Admin tools

`DELAYED_JOB_ADMIN_ENABLED` - enable the DelayedJob admin UI, 1 = on, blank = off

`DELAYED_JOB_ADMIN_USERNAME` - username for the admin UI, required for UI to be enabled
`DELAYED_JOB_ADMIN_PASSWORD` - password for the admin UI, required for UI to be enabled

## Deployment tools

`DEPLOYMENT_ID` - String to be available at `/deployment.txt` - used to check the deployed version

`DEPLOYMENT_USERNAME` - username for `deployment.txt` endpoint, defaults to a randomly generated value on start up
DEPLOYMENT_PASSWORD - password for `deployment.txt` endpoint, defaults to a randomly generated value on start up

