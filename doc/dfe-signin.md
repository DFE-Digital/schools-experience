# DfE Sign-in integration

DfE Sign-in is the SSO service provided by DfE. We use it to control access for
the Manage school experience service, ie the part of the service used by 
Schools.

## OpenID Connect

DfE Sign-in implements a standard OpenID Connect interface. This is a superset
of OAuth2.

1. Redirect from School Experience to Sign-in service
2. User authorises with Sign-in service, optionally chooses their organisation
3. User gets redirected back to School experience with a token
4. An API call is made to Sign-in using token for authentication, that api call 
retrieves the users details.

## Organisations, Services, Roles

In addition to Authentication, DfE Sign-in can also handle Authorisation. This
is implemented with 3 concepts

- Organisation - a user can belong to 0 or more organisations, typically Schools
- Service - there is a registry of all DfE services within Sign-in, School 
  experience has its own service
- Role - Each service defines its own roles, we have a single role - School 
  experience administrator. Users are then granted a role for an organisation.

Management of Organisations and Roles is handled within DfE Sign-in.

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
  