
<html>

<head>
    <link type="text/css" rel="stylesheet" href="temptablestyle.css" />
</head>

<body>

<?php
   require ('config.php');
   $connection = pg_connect ("host=$DB_HOST dbname=$DB_DATABASE user=$DB_USER password=$DB_PASSWORD");

   if($connection) {
      echo 'Connected';
   } else {
      echo 'There has been an error connecting';
   }

   $query = "INSERT INTO myTeachers (teacher_id, firstname, lastname, email) VALUES ('$_POST[id]','$_POST[firstname]','$_POST[lastname]','$_POST[email]')";
   $result = pg_query($query);

   if (!$result) {
       echo "An error while inserting occurred.\n";
       exit;
   }
?>

<div id="container">
  <table>
      <tr>
          <th>ID</th>
          <th>First name</th>
          <th>Last name</th>
          <th>Email</th>
      </tr>

      <?php
        $teachers = pg_query("SELECT * FROM myTeachers;");
           while ($row = pg_fetch_array($teachers)) {
               echo "<tr>\n";
               echo " <td>", $row["teacher_id"], "</td>
               <td>", $row["firstname"], "</td>
               <td>", $row["lastname"], "</td>
               <td>", $row["email"], "</td>
               </tr>  ";
           }
           pg_close($connection);
       ?>
   </table>
</div>

</body>
</html>
