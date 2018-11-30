#!/usr/bin/env bats -t

load ../helpers

function setup() {
    __setup ldap
}

@test "LDAP: health status is up" {
    helper_runner curl.rb get /api/v1/health
    [ $status -eq 0 ]
    [[ "${lines[-1]}" =~ "LDAP server is reachable" ]]
}
