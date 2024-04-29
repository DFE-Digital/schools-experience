# Invite users to school's DFE Sign in via Manage School Dashboard

## Identify only vs Identity and Access Management

Current DSI implementation on Manage School Experience is Identity and Access Management
which allows users to invite new users, specify their roles (end-user or approver), give
them access to organisation(s), added them to service(s), and remove them when they are
no longer in the role or organisation.

However, the user have to perform all of these actions in the DSI dashboard. They cannot
perform any of these actions in Manage School Experience.

We wanted to move to Identity only version of DSI so that we could use it just for the
purpose of authentication only and allow users greater flexibility when it came to user
management.

## Discovery

We discovered that moving to Identity only means that we have to host entirety of the
organisational data (users, roles, permissions, services etc.) and we would have to actively
manage the requests if the users cannot do that themselves.

It also meant that we would be required to build a support console in the near future so that
the GIT support team and the Schools could manage user as well as candidate requests.

We found a way to achieve the user management with the existing version of DSI by integrating
the `public api` into the Manage School Experience service.

Users will be able to invite new users via School Dashboard in Manage School Experience

The new users will be assigned an organisation they have been invite to manage and will be
assigned an ‘End-user’ role by default.

## Caveat:

- DSI only assigns an ‘end-user’ role via public API - security protocol
- DSI also does not assign service by default via public API - security protocol

## Final solution

1. Maintain the Managed instance of DSI
2. Users can invite users to the schools they are signed in to.
3. If the users need to get ‘Approver’ level access, they can reach out to DSI support
   for their request.
4. They will also be able to ask current approvers to give them access to the service.
   1. DSI help page on requesting access to a service once you're in an organisation:
      https://help.signin.education.gov.uk/services/request-access
