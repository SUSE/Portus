# API

This is a work-in-progress document that tries to achieve what I'll be doing for
this hackweek, and what it should be done in the near future regarding the API.

## Hackweek

### Authentication

There should be a way to have the authentication part working as
expected. It should be as simple as possible.

### Vulnerabilities

This will be part of the "Repositories & tags" endpoints. There should be a way
to fetch the list of vulnerabilities for the given repo + tag. Suggested paths:

* `/repositories/<image>/vulnerabilities`
* `/repositories/<image>/tags/<tag>/vulnerabilities`

Note that the second form should be clarified once I get the repositories#show
page straight. So, for now I'll only implement the first one.

## Near future

Most of these routes already exist, but they should be implemented for the new
scheme as well.

### Administration

- Create & update registries.
- Fetch activities.

### Application tokens

Not sure if this conflicts with the authentication part. If it doesn't, then the
`create` and the `destroy` actions should be re-implemented so it responds back
with JSON data.

### Namespaces & teams

All actions for creating, updating and destroying teams and namespaces.

### Repositories and tags

List and show actions should be implemented (along with the already existing
vulnerabilities endpoints).
