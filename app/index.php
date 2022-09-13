<?php
define('DB_SERVER', '172.20.0.10');
define('DB_USERNAME', 'repl');
define('DB_PASSWORD', 'Qoj3R!4GIgeq@Myz@BZ@SYSoxx');
define('DB_NAME', 'laba_db');

$set = $_GET['set'];
$get = $_GET['get'];

    date_default_timezone_set('Europe/Moscow');
    $dt = new DateTime();
    echo ("<h2>Hello Wordl!!!</h2> </br>");
    echo ("<h2>" . $dt->format('d-m-Y H:i:s') . "</h2>");


/* Attempt to connect to MySQL database */
$link = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

// Check connection
if($link === false){
    die("ERROR: Could not connect. " . mysqli_connect_error());
}

if (!empty($get)) {
	$sql = "select * from Example ORDER BY value DESC LIMIT 1";
	$result = $link->query($sql);
	$row = mysqli_fetch_object($result);
	echo ("<h2>Last value: " . $row->value . "</h2>");
}
  if (!empty($set)) {
	echo "<h2>Current value: " . $set . "</h2>";

	$sql = "insert Example set value = '$set'";
	$link->query($sql);
}
?>
