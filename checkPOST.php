<!DOCTYPE html>
<html>
<body>
   <h1> This is the content of the POST array received</h1>
   <?php
   foreach($_POST as $key => $value) {
       echo " <p>Name of variable is:  ", $key, " with value=", $value, "</p>";
   }
   ?>
</body>
</html>
