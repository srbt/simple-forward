#!/usr/bin/env bash

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  TEST_CONTEXT="${USER}-$$-${RANDOM}"
  docker network create "${TEST_CONTEXT}"

  docker build -t "${TEST_CONTEXT}-server" .

  docker run -d --name "${TEST_CONTEXT}-s1" --network "${TEST_CONTEXT}" --hostname 'frontend' "${TEST_CONTEXT}-server"
  docker run -d --name "${TEST_CONTEXT}-s2" --network "${TEST_CONTEXT}" --hostname 'backend' "${TEST_CONTEXT}-server"
  docker run -d --name "${TEST_CONTEXT}-s3" --network "${TEST_CONTEXT}" --hostname 'database' "${TEST_CONTEXT}-server"
}

teardown() {
  printf '\nlogs from frontend:\n'
  docker logs "${TEST_CONTEXT}-s1"
  printf '\nlogs from backend:\n'
  docker logs "${TEST_CONTEXT}-s2"
  printf '\nlogs from database:\n'
  docker logs "${TEST_CONTEXT}-s3"
  printf '\n\nCleaning up...\n'
  docker rm -f "${TEST_CONTEXT}-s1" "${TEST_CONTEXT}-s2" "${TEST_CONTEXT}-s3"
  docker network rm "${TEST_CONTEXT}"
}

@test "simple-server is working" {
  run docker run --rm --network "${TEST_CONTEXT}" "${TEST_CONTEXT}-server" -r 'echo file_get_contents("http://frontend:8080?target1=backend:8080&target2=database:8080");'
  assert_success
  assert_output 'frontend: Calling http://backend:8080?target2=database%3A8080
> backend: Calling http://database:8080?
> > database: No next hop
> > 
> '
}
