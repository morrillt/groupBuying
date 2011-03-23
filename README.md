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

# Monitoring of cralwers and snapshots

All output is redirected to the log dir.
You can view all output in a stream with `tail -f`

`cd /srv/gbd/current && tail -f log/crawler.log log/snapshot.log log/deal_closer.log        


Running resque and jobs scheduler
=================================

# Run workers:
Simple workers can be ran with:  
  $ RAILS_ENV=production COUNT=5 QUEUE=* rake resque:workers
  
Workers can be separated by queues [crawler, deals, snapshots]:
  $ RAILS_ENV=production COUNT=5 QUEUE=crawler,deals rake resque:workers
  $ RAILS_ENV=production COUNT=1 QUEUE=snapshots rake resque:workers

# Run scheduler:
  $ rake resque:scheduler  

Web interface mounted to /resque path