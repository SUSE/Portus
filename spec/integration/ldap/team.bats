#!/usr/bin/env bats -t

load ../helpers

function setup() {
    __setup ldap
}

@test "LDAP: groupOfUniqueNames: team members are added automatically when team gets created" {
    helper_runner ldap.rb flordeneu fada
    [ $status -eq 0 ]

    helper_runner ldap.rb gentil tallaferro
    [ $status -eq 0 ]

    helper_runner curl.rb post /api/v1/teams flordeneu name=lopirineu
    [ $status -eq 0 ]

    helper_runner wait_ldap_check.rb team
    [ $status -eq 0 ]

    ruby_puts "Team.find_by(name:\"lopirineu\").users.map(&:username).join(\",\")"
    [ $status -eq 0 ]
    [[ "${lines[-1]}" =~ "flordeneu,gentil" ]]
}

@test "LDAP: groupOfUniqueNames: team members are added automatically when user logs in for the first time" {
    helper_runner ldap.rb flordeneu fada
    [ $status -eq 0 ]

    helper_runner curl.rb post /api/v1/teams flordeneu name=lopirineu
    [ $status -eq 0 ]

    helper_runner wait_ldap_check.rb team
    [ $status -eq 0 ]

    helper_runner ldap.rb gentil tallaferro
    [ $status -eq 0 ]

    helper_runner wait_ldap_check.rb user
    [ $status -eq 0 ]

    ruby_puts "Team.find_by(name:\"lopirineu\").users.map(&:username).join(\",\")"
    [ $status -eq 0 ]
    [[ "${lines[-1]}" =~ "flordeneu,gentil" ]]
}

@test "LDAP: team members are not added if the team has been disabled" {
    helper_runner ldap.rb flordeneu fada
    [ $status -eq 0 ]

    helper_runner curl.rb post /api/v1/teams flordeneu name=lopirineu
    [ $status -eq 0 ]

    helper_runner wait_ldap_check.rb team
    [ $status -eq 0 ]

    helper_runner curl.rb post /api/v1/teams/:id/ldap_check flordeneu
    [ $status -eq 0 ]

    helper_runner ldap.rb gentil tallaferro
    [ $status -eq 0 ]

    helper_runner wait_ldap_check.rb user
    [ $status -eq 0 ]

    ruby_puts "Team.find_by(name:\"lopirineu\").users.map(&:username).join(\",\")"
    [ $status -eq 0 ]
    [[ "${lines[-1]}" =~ "flordeneu" ]]
}

@test "LDAP: groupOfNames: team members are added automatically when team gets created" {
    helper_runner ldap.rb flordeneu fada
    [ $status -eq 0 ]

    helper_runner ldap.rb gentil tallaferro
    [ $status -eq 0 ]

    helper_runner curl.rb post /api/v1/teams flordeneu name=arria
    [ $status -eq 0 ]

    helper_runner wait_ldap_check.rb team
    [ $status -eq 0 ]

    ruby_puts "Team.find_by(name:\"arria\").users.map(&:username).join(\",\")"
    [ $status -eq 0 ]
    [[ "${lines[-1]}" =~ "flordeneu,gentil" ]]
}

@test "LDAP: groupOfNames: team members are added automatically when user logs in for the first time" {
    helper_runner ldap.rb flordeneu fada
    [ $status -eq 0 ]

    helper_runner curl.rb post /api/v1/teams flordeneu name=arria
    [ $status -eq 0 ]

    helper_runner wait_ldap_check.rb team
    [ $status -eq 0 ]

    helper_runner ldap.rb gentil tallaferro
    [ $status -eq 0 ]

    helper_runner wait_ldap_check.rb user
    [ $status -eq 0 ]

    ruby_puts "Team.find_by(name:\"arria\").users.map(&:username).join(\",\")"
    [ $status -eq 0 ]
    [[ "${lines[-1]}" =~ "flordeneu,gentil" ]]
}
