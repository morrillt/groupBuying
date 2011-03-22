<?php
require_once('config.php');

		$connection = @mysql_connect ( $hostname, $username, $password );
		if (! $connection) {
			die ( "Fatal Error: Could not connect to database server." );
		}
		if (! @mysql_select_db ( $database )) {
			die ( "Fatal Error: Could not select database." );
		}
		
		if(!$fields){
			$result = @mysql_query("SHOW COLUMNS FROM $table");
			if (mysql_num_rows($result) > 0) {
			   while ($row = mysql_fetch_assoc($result)) {
				   $fields[$row['Field']] = $row['Field'];
			   }
			}
		}
		
		$get_search = mysql_real_escape_string($_GET['search']);
		$get_start = mysql_real_escape_string($_GET['start']);
		$get_direction = mysql_real_escape_string($_GET['direction']);
		$get_order_by = mysql_real_escape_string($_GET['order_by']);
		

		if($get_search){ 
			if(!$searchField){
				$search_sql = " WHERE ";
				foreach($fields as $key=>$val){
				$search_sql .= "$key LIKE '%$get_search%' OR ";
				}
				$search_sql = substr($search_sql,0,-4);
			} else {			
				$search_sql = " WHERE $searchField LIKE '%$get_search%' ";
			}
			
		}

		if($get_start){ $start = $get_start; } else { $start = "0"; }
		if($get_direction){ $direction = $get_direction; }
		if($direction=="ASC"){$direction="DESC";} else { $direction="ASC";}
		if($get_order_by){ $order_by = " ORDER BY $get_order_by " . $direction; } else { $order_by = " "; }
		
		if($sortField && !$get_order_by){
		  $get_order_by = $sortField;
		  $direction = $sortOrder;
		  $order_by = " ORDER BY $get_order_by " . $direction;
		}
		
?>
<div class="tableBorder">
<table class="ajaxTable" cellpadding="0" cellspacing="0" border="0">
	<thead>
		<tr>
		<?php
		  foreach($fields as $key => $val){
		    if($key == $get_order_by){ $imgsrc = "$direction.gif"; $sort = $direction; } else { $imgsrc = "arrows_updown.gif"; $sort = "DESC"; }
				echo "<th><a href=\"#\" onclick=\"javascript:sortTable('$key','$sort');\">$val<img id=\"$key\" src=\"$imgsrc\" /></a></th>";
			}
		?>
		</tr>
	</thead>
<tbody>
	<?php
		$sql = "SELECT count(*) AS num FROM $table $search_sql $order_by LIMIT $pageLimit";
		$result = mysql_query ( $sql );
		$rowCount = mysql_result($result,0,"num");

		foreach($fields as $key => $val){
			$select_fields .= $key . ",";
		}
		$select_fields = substr($select_fields,0,-1);

		$sql = "SELECT $select_fields FROM $table $search_sql $order_by LIMIT $start, $pageLimit";
		$row = mysql_query ( $sql );
		
		while ( $result = mysql_fetch_array ( $row ) ) {
			if ( $x&1 ){ echo "<tr class=\"tdOdd\">"; } else { echo "<tr class=\"tdEven\">"; }
			
			foreach($fields as $key => $val){
				echo "<td>" . $result[$key] . "</td>";
			}

			echo "</tr>";
			$x++;
		}
		
		$numberOfPages = ceil($rowCount / $pageLimit);
	?>
</tbody>
<tfoot>
	<tr><td colspan="30"><h2><?php echo $rowCount . " Results - " . $numberOfPages . " Pages"; ?></h2></td></tr>
</tfoot>
</table>
</div>

<div class="pagination">
<?php
$current_page = ceil($start / $pageLimit) + 1;
$x=1;
$start=0;

if($current_page<=9){
	while($x<=$numberOfPages){
		if($x<=10){
			if($current_page == $x){$class="paginationSelected";} else { $class="";}
			echo "<a href=\"#\" class=\"$class\" onclick=\"javascript:gotoStart($start);\">$x</a> ";
		}
		if($x>10 && $x == $numberOfPages){
			echo " ... <a href=\"#\" onclick=\"javascript:gotoStart($start);\">$x</a> ";
		}
	$start = $start + $pageLimit;
	$x++;
	}
}

$x=1;
if($current_page>=10){
	$pageCounter = $current_page - 5;
	while($x<=10){
		$pageNumber = $pageCounter * $pageLimit - $pageLimit;
		if($pageCounter<=$numberOfPages){
			if($current_page == $pageCounter){$class="paginationSelected";} else { $class="";}
			echo "<a href=\"#\" class=\"$class\" onclick=\"javascript:gotoStart($pageNumber);\">$pageCounter</a> ";
		}
	$pageCounter++;
	$x++;
	}
}

?>
</div>