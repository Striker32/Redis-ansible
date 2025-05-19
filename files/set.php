<?php
$redis = new Redis();
$redis->connect('127.0.0.1', 6379);

$key = $_POST['key'];
$value = $_POST['value'];

if ($key && $value) {
    $redis->set($key, $value);
    echo "Key '$key' set to '$value'";
} else {
    echo "Key or value missing!";
}
?>
