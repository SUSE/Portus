# Function taken from openSUSE/umoci. See:
# https://github.com/openSUSE/umoci/blob/57c73c27fe3c13d80e1fb7f82c9a046a2bc2b6f1/test/helpers.bash#L116-L125
function sane_run() {
	local cmd="$1"
	shift

	run "$cmd" "$@"

	# Some debug information to make life easier.
	echo "$(basename "$cmd") $@ (status=$status)" >&2
	echo "$output" >&2
}

# Wrapper for the docker command.
function docker_run() {
    sane_run docker $@
}

# It accepts two parameters: the old tag and the new tag. This function will
# first remove any reference to the new tag, and then perform a docker tag.
function docker_tag() {
    docker_run rmi -f $2
    docker_run tag $1 $2
}

# Performs a docker exec into the Portus container.
function docker_exec() {
    docker_run exec $CNAME $@
}

# Performs a portusctl exec inside of the Portus container.
function portusctl_exec() {
    docker_exec portusctl exec $@
}

# Run the given runner with the given arguments.
function helper_runner() {
    local file="$1"
    shift

    portusctl_exec rails runner /srv/Portus/spec/integration/helpers/$file $@
}

# Runs the `spec/integration/helpers/eval.rb` runner by passing the given
# argument.
function ruby_puts() {
    helper_runner eval.rb $1
}

# Setup the database for each test case. It accepts an argument which can be
# used to determine the profile to be loaded on the database.
function __setup_db() {
    portusctl_exec rails r /srv/Portus/spec/integration/profiles/$1.rb
}

# Logout the current user. Perform this before each test.
function __logout() {
    docker_run logout 172.17.0.1:5000
}

# Cleanup the data from the registry.
function __clear_registry() {
    docker_run exec $RNAME rm -rf /var/lib/registry/docker/registry/v2/*
}

# Restart the given services.
function __restart() {
    pushd $ROOT_DIR/build
    sane_run docker-compose restart $@
    popd
}

# The main function to be called on `setup`. It accepts an argument, which will
# be directly passed to the `__setup_db` function.
function __setup() {
    __setup_db $1
    __logout
    __clear_registry
}
