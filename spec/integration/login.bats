#!/usr/bin/env bats -t

load helpers

function setup() {
    __setup minimal
}

@test "proper user can run docker login" {
    docker_run login -u admin -p 12341234 172.17.0.1:5000
    [ $status -eq 0 ]
    # The first line is a warning because we are passing the password directly
    # from the CLI.
    [[ "${lines[1]}" =~ "Login Succeeded" ]]
}

@test "unknown user cannot login" {
    docker_run login -u user -p 12341234 172.17.0.1:5000
    [ $status -eq 1 ]
    [[ "${lines[1]}" =~ "authentication required" ]]
}
