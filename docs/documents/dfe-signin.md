# DfE Sign-in integration

DfE Sign-in is the SSO service provided by DfE. We use it to control access for
the Manage school experience service, ie the part of the service used by Schools.

## OpenID Connect

DfE Sign-in implements a standard OpenID Connect interface. This is a superset
of OAuth2.

1. Redirect from School Experience to Sign-in service
2. User authorises with Sign-in service, optionally chooses their organisation
3. User gets redirected back to School experience with a token
4. An API call is made to Sign-in using token for authentication, that api call
   retrieves the users details.

### Expired application session during callback

The OIDC `state` value is stored in the application session when sign-in starts.
If that saved value is missing or blank when the callback arrives (for example
because the session expired before the user returned from Sign-in), the callback
is discarded and the user is sent to the school dashboard to restart sign-in.
This is logged as a warning and is not reported to Sentry, and no code exchange,
userinfo request or role check happens for that callback.

A callback where the saved `state` is present but the callback's `state` is
missing, blank or different is treated as a genuine state mismatch. It is
reported to Sentry and the user is redirected to the authentication failure page.

## Organisations, Services, Roles

In addition to Authentication, DfE Sign-in can also handle Authorisation. This
is implemented with 3 concepts

- Organisation - a user can belong to 0 or more organisations, typically Schools
- Service - there is a registry of all DfE services within Sign-in, School
  experience has its own service
- Role - Each service defines its own roles, we have a single role - School
  experience administrator. Users are then granted a role for an organisation.

Management of Organisations and Roles is handled within DfE Sign-in, however,
users can invite new users to their organisation from the school dashboard within
Manage School Experience.

## Organisation selection

Currently we request an organisation as well as a user from DfE Sign-in. When
the user signs in, they choose their organisation as part of the sign-in
process.

If the user administers multiple schools and wishes to change the school they
are operating on behalf of, we redirect them back to Sign-in to choose a
different school.

This approach has limits since we cannot enhance that screen, and we only know
about 1 organisation at a time.

### SE School chooser

We have an alternative integration, which only requests a user from DfE Sign-in
and we then do the School selection within the School experience application.
This is achieved via API calls to query the
[Sign-in public API](https://github.com/DFE-Digital/login.dfe.public-api)
