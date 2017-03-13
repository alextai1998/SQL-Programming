<?php
// --- secure connection to the database
require ("config.php");
$connection = pg_connect ("host=$DB_HOST dbname=$DB_DATABASE user=$DB_USER password=$DB_PASSWORD");

// Check connection
if (!$connection){
    echo "Connection error";
}

$name = $_POST['username'];
$pass = $_POST['password'];

$query = "SELECT * FROM users WHERE username='$name' AND password=crypt('$pass', password);"

$result = pg_fetch_array(pg_query($query));

echo "The result is".$result[0]

?>