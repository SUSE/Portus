#!/usr/bin/env bats -t

load helpers

function setup() {
    __setup full
}

@test "updates the database after a successful push" {
    docker_run login -u admin -p 12341234 172.17.0.1:5000
    [ $status -eq 0 ]

    docker_tag $DEVEL_IMAGE 172.17.0.1:5000/test:uniquetag
    docker_run push 172.17.0.1:5000/test:uniquetag
    [ $status -eq 0 ]

    helper_runner wait_event_done.rb uniquetag
    [ $status -eq 0 ]

    ruby_puts "Tag.count"
    [[ "${lines[-1]}" =~ "1" ]]

    ruby_puts "Tag.first.name"
    [[ "${lines[-1]}" =~ "uniquetag" ]]
}

@test "updates the database after a successful delete" {
    docker_run login -u admin -p 12341234 172.17.0.1:5000
    [ $status -eq 0 ]

    docker_tag $DEVEL_IMAGE 172.17.0.1:5000/test:uniquetag
    docker_run push 172.17.0.1:5000/test:uniquetag
    [ $status -eq 0 ]

    helper_runner wait_event_done.rb uniquetag
    [ $status -eq 0 ]

    ruby_puts "Tag.count"
    [[ "${lines[-1]}" =~ "1" ]]

    # And now let's delete this tag.
    helper_runner delete.rb test uniquetag
    [ $status -eq 0 ]

    helper_runner wait_event_done.rb uniquetag pickfirst
    [ $status -eq 0 ]

    ruby_puts "Tag.count"
    [[ "${lines[-1]}" =~ "0" ]]
}
