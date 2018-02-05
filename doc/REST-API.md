# REST API

Portus REST API for creating and managing users and their tokens.

## API authentication

All queries require an authenticated application token.
Also make sure that the API user has admin rights.
The token should be send with the request header param "PORTUS-AUTH"

```
request.headers["PORTUS-AUTH"]: "username:token"
```
If the authentication fails, then the HTTP status code 401 is returned. If authorization fails a 403 status code is returned.


## OpenAPI Specification

OpenAPI Specification (aka The Swagger Specification) can be fetched from the running Portus instance by visiting the URL `/api/openapi-spec` e.g.
[localhost:3000/api/openapi-spec](http://localhost:3000/api/openapi-spec) or executing the rake command `rake oapi:fetch`

To display the results in a more human readable form you can use the [Swagger UI](http://petstore.swagger.io/) and import the above URL.
