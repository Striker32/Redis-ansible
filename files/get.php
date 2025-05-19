<?php
$redis = new Redis();
$redis->connect('127.0.0.1', 6379);

$key = $_GET['key'];

if ($key) {
    $value = $redis->get($key);
    if ($value) {
        echo "Value for '$key': $value";
    } else {
        echo "Key '$key' not found";
    }
} else {
    echo "Key is missing!";
}
?>
