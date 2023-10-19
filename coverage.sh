#!/bin/bash

set -e

# create lcov report file
forge coverage --report lcov

lcov --remove ./lcov.info -o ./lcov.info.pruned 'test/' 'script/'

lcov \
    --rc lcov_branch_coverage=1 \
    --list ./lcov.info.pruned
