#!/usr/bin/env bats -t

load helpers

function setup() {
    __setup minimal
}

@test "health runs just fine" {
    helper_runner curl.rb get /api/v1/health
    [[ "${lines[-1]}" =~ "database is up-to-date" ]]
    [[ "${lines[-1]}" =~ "clair is reachable" ]]
    [[ "${lines[-1]}" =~ "registry is reachable" ]]
}

@test "health reports an invalid registry" {
    # Modify the registry hostname to some unknown hostname.
    ruby_puts "Registry.get.update(hostname:\"wrong.whatever\")"

    helper_runner curl.rb get /api/v1/health
    [ $status -eq 1 ]
    [[ "${lines[-2]}" =~ "SocketError: connection refused" ]]
}
