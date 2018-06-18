#!/usr/bin/env bats -t

load ../helpers

function setup() {
    __setup ldap
}

@test "LDAP: proper user can login" {
    helper_runner ldap.rb jverdaguer folgueroles
    [ $status -eq 0 ]
    [[ "${lines[-1]}" =~ "name: jverdaguer, email: , admin: true, display_name:" ]]
}

@test "LDAP: bad password" {
    helper_runner ldap.rb jverdaguer vic
    [ $status -eq 1 ]
    [[ "${lines[-2]}" =~ "Invalid Credentials (code 49)" ]]
}

@test "LDAP: unknown user" {
    helper_runner ldap.rb jcarner arbres
    [ $status -eq 1 ]
    [[ "${lines[-2]}" =~ "Could not find user 'jcarner'" ]]
}

@test "LDAP: certificate signed by unknown CA" {
    helper_runner ldap.rb jverdaguer folgueroles encryption:options:ca_file=""
    [ $status -eq 1 ]
    [[ "${lines[-2]}" =~ "certificate verify failed" ]]
}

@test "LDAP: no certificate was provided" {
    helper_runner ldap.rb jverdaguer folgueroles encryption:method=""
    [ $status -eq 1 ]
    [[ "${lines[-2]}" =~ "Confidentiality Required (code 13)" ]]
}

@test "LDAP: wrong SSL version" {
    helper_runner ldap.rb jverdaguer folgueroles encryption:options:ssl_version="TLSv1_1"
    [ $status -eq 1 ]
    [[ "${lines[-2]}" =~ "SSL_connect SYSCALL" ]]
}

@test "LDAP: could not connect to server" {
    helper_runner ldap.rb jverdaguer folgueroles hostname="unknown"
    [ $status -eq 1 ]
    [[ "${lines[-2]}" =~ "getaddrinfo: Name or service not known" ]]
}

@test "LDAP: wrong authentication" {
    helper_runner ldap.rb jverdaguer folgueroles authentication:password="wrong"
    [ $status -eq 1 ]
    [[ "${lines[-2]}" =~ "No Such Object (code 32)" ]]
}

@test "LDAP: portus user is skipped" {
    ruby_puts "Registry.get.client.catalog.inspect"
    [ $status -eq 0 ]
}

@test "LDAP: portus user is skipped" {
    helper_runner ldap.rb pfabra giecftw1918
    [ $status -eq 0 ]
    [[ "${lines[-1]}" =~ "Soft fail: Bot user is not expected to be present on LDAP" ]]
}
