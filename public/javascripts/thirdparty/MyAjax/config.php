<?php
		//MySQL
		$hostname = "localhost";
		$username = "root";
		$password = "";
		$database = "";
		$table = "";
		
		//Fields to display "MySQL Field Name"=>"Column Title". Leave blank to display ALL database fields
		//e.g. "id"=>"Rank","ManufacturerMake"=>"Manuf"
		$fields = array(); 
		//Results per page
		$pageLimit = 25;
		//Which field Ajax search should perform on. Leave blank to search ALL fields
		$searchField = "";
		//Which field to initially sort on. Leave blank to not sort on any field.
		$sortField = "";
		//Ascending or Descending initial sort order.
		$sortOrder = "ASC";
?>