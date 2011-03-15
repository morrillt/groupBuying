Importers
==============================
  The importers run every hour and fetch data from various sources.
  This whole process is monitored by god using the config/importer.god file.
  

Deployment
==============================
  cap `RAILS_ENV` deploy
  
  e.g. cap staging deploy
  or cap production deploy
  
  Tips:
  
  To see what is deployed currently in any environment you can use this task.
  
  cap staging deploy:pending:diff # this will show a diff of whats on staging and whats not.
  
  rolling back is simple
  
  cap staging deploy:rollback
  
  This will symlink the current path the previous release directory given one exists.

Testing
==============================
  bundle exec autotest

NOTES About God Setup
==============================
The binary /usr/bin/god is a symlink
lrwxrwxrwx 1 root 55 Mar 15 19:46 /usr/bin/god -> /srv/gbd/shared/bundle/ruby/1.8/gems/god-0.11.0/bin/god

this makes calling god simpler as you only need to call `god [args]`

