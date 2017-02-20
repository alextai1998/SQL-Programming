<html>
<body>
<?php
   // require ('config.php');
   $connection = pg_connect ("host=192.168.1.121 dbname=sqlClass user=alextai password=#1998#Alex");

   if($connection) {
      echo 'Connected';
   } else {
       echo 'There has been an error connecting';
   }

   $query = "INSERT INTO myTeachers (teacher_id, firstname, lastname, email) VALUES ('$_POST[id]','$_POST[firstname]','$_POST[lastname]','$_POST[email]')";
   $result = pg_query($query);

   if (!$result) {
   echo "An error occurred.\n";
   exit;
   }

?>
</body>
</html>
