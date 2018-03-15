#!/usr/bin/env bats -t

load helpers

function setup() {
    __setup full
}

##
# Pushing into the global namespace.

@test "admin user can push to the global namespace" {
    docker_run login -u admin -p 12341234 172.17.0.1:5000
    [ $status -eq 0 ]

    docker_tag $DEVEL_IMAGE 172.17.0.1:5000/test:development
    docker_run push 172.17.0.1:5000/test:development

    [ $status -eq 0 ]
    [[ "${lines[-1]}" =~ "development: digest: sha256:" ]]
}

@test "admin user can push multiple tags at once to the global namespace" {
    docker_run login -u admin -p 12341234 172.17.0.1:5000
    [ $status -eq 0 ]

    docker_tag $DEVEL_IMAGE 172.17.0.1:5000/test:development
    docker_tag $DEVEL_IMAGE 172.17.0.1:5000/test:development2
    docker_run push 172.17.0.1:5000/test

    [ $status -eq 0 ]
}

@test "regular user cannot push into the global namespace" {
    docker_run login -u user -p 12341234 172.17.0.1:5000
    [ $status -eq 0 ]

    docker_tag $DEVEL_IMAGE 172.17.0.1:5000/test:development
    docker_run push 172.17.0.1:5000/test:development

    [ $status -eq 1 ]
    [[ "${lines[-1]}" =~ "authentication required" ]]
}

@test "push fails if the hostname of the registry is not properly set" {
    export PORTUS_INTEGRATION_HOSTNAME="whatever:4000"
    __setup_db full

    docker_run login -u user -p 12341234 172.17.0.1:5000

    docker_tag $DEVEL_IMAGE 172.17.0.1:5000/test:development
    docker_run push 172.17.0.1:5000/test:development
    [ $status -eq 1 ]
}

##
# Pushing into namespace.

@test "pushing in a namespace with contributors and viewers" {
    docker_run login -u user -p 12341234 172.17.0.1:5000
    [ $status -eq 0 ]

    # Contributor can push and pull

    docker_tag $DEVEL_IMAGE 172.17.0.1:5000/namespace/test:development
    docker_run push 172.17.0.1:5000/namespace/test:development
    [ $status -eq 0 ]

    docker_run pull 172.17.0.1:5000/namespace/test:development
    [ $status -eq 0 ]

    # Viewer can only push

    __logout
    docker_run login -u viewer -p 12341234 172.17.0.1:5000

    docker_run push 172.17.0.1:5000/namespace/test:development
    [ $status -eq 1 ]

    docker_run pull 172.17.0.1:5000/namespace/test:development
    [ $status -eq 0 ]
}
