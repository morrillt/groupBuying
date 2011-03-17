GroupBuying Application
===============================

Installation
===============================

  Install the required gems
  `bundle install`

  Create the database
  `rake db:create`

  Create the schema
  `rake db:migrate`


Running the application
===============================

`rails s`

Running the importers and snapshooters
============================================

# The importer
`RAILS_ENV=production /app_path/bin/crawl`

# The snapshooter
`RAILS_ENV=production /app_path/bin/snapshot`
