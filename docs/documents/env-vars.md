# Environment Variables

The school experience application supports various environment variables
to control different aspects of the application.

These can be configured as part of your shell or more easily by editing the
`.env` file. Optionally `.env.development` / `.env.test` files can be created for
environment specific variables.

Full documentation is at
[https://github.com/bkeepers/dotenv/blob/master/README.md](https://github.com/bkeepers/dotenv/blob/master/README.md)

## HTTP Basic Auth access control

If its required to password protect then entire application then you can set two
environment variables when booting the app. This can either be part of the
deployment configuration.

`SECURE_USERNAME` username for http auth

`SECURE_PASSWORD` password for http auth

## Exception notification

If required Exceptions Notifications can be sent to Sentry.

`SENTRY_DSN` - Send exception reports to sentry, config value supplied by Sentry. An organisation owner or #digital-tools-support can add new members to the school-experience team in the org dfe-teacher-services. Then a new key can be generated via https://sentry.io/settings/dfe-teacher-services/projects/school-experience/keys/.

## Gitis configuration

`CRM_PRIVACY_CONSENT_ID` - GUID for the privacy policy consent id used by candidates - supplied by Gitis team

`GIT_API_TOKEN` - [API key for the GiT API](https://dfedigital.atlassian.net/wiki/spaces/GGIT/pages/2257682445/API-KEYS).

## DFE Sign-in configuration

`DFE_SIGNIN_SECRET` - Secret string used to encore/decode the payload when communicating with DSI. It it generated on the manage service page in OpenID Connect / Client secret

`DFE_SIGNIN_API_ENDPOINT` - DSI API endpoint to access extra data from the API. May point to preprod or prod DSI environment.

`DFE_SIGNIN_API_SECRET` - Secret string used to decode the payload from DSI API. It it generated on the manage service page in API / Secret.

`DFE_SIGNIN_BASE_URL` - URL for the site which DfE Sign-in OIDC flow will link back to. Shown on DSI /my-services page. It it set on the manage service page in Service details / Home Url.

`DFE_SIGNIN_CLIENT_ID` - Client ID used to connect to DSI via OIDC. It it set on the manage service page in OpenID Connect / Client Id.

`DFE_SIGNIN_HOST` - DSI OIDC environment endpoint for authentication. May point to preprod or prod DSI environment.

`DFE_SIGNIN_API_ENABLED` - Enhance the integration using the Sign-in API, also turns on check if the user belongs to multiple organisations, 1 = on, blank = off

`DFE_SIGNIN_API_ROLE_CHECK_ENABLED` - Enables checking the user supplied by DfE Sign-in has the appropriate role over the Organisation supplied by DfE Sign-in

`DFE_SIGNIN_API_SCHOOL_CHANGE_ENABLED` - Moves choosing an organisation from the Sign-in chooser to the the Change school screen within the app.

`DFE_SIGNIN_SCHOOL_EXPERIENCE_ADMIN_SERVICE_ID` - UUID of the School experience service within the designated Sign-in environment, needed for the role check functionality. It can be found in the URL of the manage service.

`DFE_SIGNIN_SCHOOL_EXPERIENCE_ADMIN_ROLE_ID` - UUID of the School experience administrator role within the designated Sign-in environment, needed for the role check functionality. It can be found in the manage service in the Manage roles section.

`DFE_SIGNIN_API_CLIENT` - Sets the iss claim in the payload. The "iss" (issuer) claim identifies the principal that issued the JWT. It it set on the manage service page in OpenID Connect / Client Id.

`DFE_SIGNIN_HEALTHCHECK_USER_ID` - The DfE Sign In User Id to use when performing a healthcheck to verify that the DfE Sign In service is alive (this will be used in the call to `dfe_sign_in_api_host/users/<USER-ID>/organisations`). It will need to be a valid User ID, not a randomly generated GUID.

## Other integrations

`NOTIFY_API_KEY` - API key used to send emails via Notify. Tech leads and senior developers have access to the Notify account.

`GOOGLE_MAPS_KEY` - API key used to query Google Maps. Created in the "Becoming a Teacher" Google cloud project.

`GTM_ID` - Google Tag Manager account id

`SLACK_WEBHOOK` - Webhook to communicate pipeline events to Slack channel. A new token may be generated on Slack app https://ukgovernmentdfe.slack.com/apps/A02HUD62ADP-school-experience-deployments. New collaborators may be added by existing collaborators or #digital-tools-support.

## Deactivating the service

`MAINTENANCE_MODE` - Put entire service into maintenance mode, 1 = on, blank = off

`DFE_SIGNIN_DEACTIVATED` - Disable sign-in, useful if their is a Sign-in outage - 1 = on, blank = off

`DEACTIVATE_CANDIDATES` - Deactivates candidate applications, including searching

## Database configuration

`DATABASE_URL` - normal rails variable

`DB_HOST` - postgres host, defaults to nil - ie, use socket

`DB_DATABASE` - name of database to use

`DB_USERNAME` - username for postgres

`DB_PASSWORD` - password for postgres

REDIS_URL - url for Redis server, defaults to local Redis server

## Redirection

`CANONICAL_DOMAIN` - if set, connections via a different domain are redirected to the canonical one

## Deployment tools

`DEPLOYMENT_ID` - String to be available at `/healthcheck` - used to check the deployed version

## Other

`CANDIDATE_URN_WHITELIST` - Comma separated whitelist of school URNS which will always be shown in the search results.

`SECRET_KEY_BASE` - Key used by Rails to verify the integrity of signed cookies.
