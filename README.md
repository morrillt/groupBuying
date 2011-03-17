GroupBuying Application
===============================

Installation
===============================

`bundle install`

`rake db:create`

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
