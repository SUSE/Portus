#!/usr/bin/env bats -t

load ../helpers

function setup() {
    __setup ldap
}

@test "LDAP: you can create a user that doesn't exist" {
    helper_runner curl.rb post /api/v1/users rllull user.username=mrodoreda,user.email=lala@example.org,user.password=12341234
    [ $status -eq 0 ]
    [[ "${lines[-1]}" =~ "\"username\":\"mrodoreda\"" ]]
}

@test "LDAP: you cannot create an existing user" {
    helper_runner curl.rb post /api/v1/users rllull user.username=jverdaguer,user.email=lala@example.org,user.password=12341234
    [ $status -eq 1 ]
    [[ "${lines[-2]}" =~ "Use another name to avoid name collision" ]]
}
