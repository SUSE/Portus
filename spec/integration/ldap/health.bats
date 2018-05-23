#!/usr/bin/env bats -t

load ../helpers

function setup() {
    __setup ldap
}

@test "LDAP: health status is up" {
    helper_runner curl.rb /api/v1/health
    [[ "${lines[-2]}" =~ "LDAP server is reachable" ]]
}
