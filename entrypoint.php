<?php

function logArgs($args) {
  file_put_contents('php://stdout', json_encode(["message" => "start", "args" => $args]) . "\n");
}

function findTarget($args) {
  for ($i = 0; $i < 10; $i++) {
    if (array_key_exists("target{$i}", $args)) {
      return $i;
    }
  }
  return false;
}

function getTargetUrl($args, $i) {
  $target = $args["target{$i}"];
  $protocol = array_key_exists("protocol{$i}", $args) ? $args["protocol{$i}"] : "http";
  $remainingArgs = array_filter($args, function($key) use ($i) {
    return !in_array($key, ["target{$i}", "protocol{$i}"]);
  }, ARRAY_FILTER_USE_KEY);

  return "{$protocol}://{$target}?".http_build_query($remainingArgs);
}

header('Content-Type: text/plain');

$args = $_GET;
$hostname = gethostname();

logArgs($args);

$target = findTarget($args);

if ($target === false) {
  file_put_contents('php://stdout', json_encode(["message" => "no next hop"]) . "\n");
  echo "{$hostname}: No next hop\n";
  exit(0);
}

$url = getTargetUrl($args, $target);
file_put_contents('php://stdout', json_encode(["message" => "calling", "url" => $url]) . "\n");
echo "{$hostname}: Calling $url\n";
$result = @file_get_contents($url);
if ($result === false) {
  echo "{$hostname}: Error: " . error_get_last()["message"] . "\n";
  file_put_contents('php://stdout', json_encode(["message" => "error", "error" => error_get_last()]) . "\n");
}  else {
  foreach (explode("\n", $result) as $line) {
    echo "> {$line}\n";
  }
  file_put_contents('php://stdout', json_encode(["message" => "done", "status" => $http_response_header[0]]) . "\n");
}
