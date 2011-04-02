db.system.namespaces.find({name: /tmp.mr/}).forEach(function(z) {
  try{
    db.getMongo().getCollection( z.name ).drop();
  } catch(err) {}
});