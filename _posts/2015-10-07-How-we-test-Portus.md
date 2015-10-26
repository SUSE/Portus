---
layout: post
title:  "How we test Portus"
date:   2015-10-07 17:27:10
categories: documentation
---

## Tools being used

All the tests have been written with [RSpec](http://rspec.info/), with some extra candy so it integrates flawlessly with the other tools that we are using. The test suite is located inside the `spec` directory, and it can be run like this:

```bash
# Make sure to have have executed `bundle` before performing this.
$ bundle exec rspec spec
```

The acceptance tests are particularly slower. This is because for these tests we use the combination [Capybara](http://jnicklas.github.io/capybara/) + [Poltergeist](https://github.com/teampoltergeist/poltergeist), and it requires the database to be truncated before running each test.

After all the tests have been run, we make a last check with [SimpleCov](https://github.com/colszowka/simplecov). This gem checks that the code coverage status is at 100%. This is the way in which we make sure that our test suite is as thorough as possible.

## Continuous integration

Every commit being pushed in the master branch (and every Pull Request against the master branch) goes through our continuous integration procedure. This consists on the following steps:

1. [Travis-CI](https://travis-ci.org/SUSE/Portus) runs the test suite and `rubocop`. This way, Travis-CI makes sure that all tests are passing and that the submitted code is accepted by our code style. You can find the `.travis.yml` file being used [here](https://github.com/SUSE/Portus/blob/master/.travis.yml).
2. After that, the change gets sent to [CodeClimate](https://codeclimate.com/github/SUSE/Portus). CodeClimate checks the health of the codebase after the push has been made, and lastly it checks the code coverage of the test suite. Note that we get two reports for the code coverage: one from CodeClimate, and the other from SimpleCov. Also note that this step is skipped for Pull Requests.
3. Last but not least, on success the results will be pushed to the [Open Build Service](https://build.opensuse.org/) through [this script](https://github.com/SUSE/Portus/blob/master/packaging/suse/package_and_push_to_obs.sh). Note that, just like the previous step, this will be skipped for Pull Requests.

## The Appliance

In order to test the appliance, we have a jenkins job that gets the image from the Open Build Service, imports it to an openStack cloud instance and launches an instance. In order to do so, we make use of [the obs2openstack script](https://gitlab.suse.de/jordimassaguerpla/ci-scripts/blob/master/obs2openstack.sh).

Then the instance needs a manual interaction in order to configure it. One needs to go to the "console" and go through the yast2 firstboot workflow. When the yast2 firstboot workflow finishes, then the appliance will have network, not before.

Once the instance has network, we have a jenkins job that will run the scripts from [appliance-test subdir](https://github.com/SUSE/Portus/tree/master/packaging/suse/appliance-test).

In order to run the previous scripts, we make use of the [run_in_obs script](https://gitlab.suse.de/jordimassaguerpla/ci-scripts/blob/master/run_in_os.sh).
