# Yaml file contain api keys for categories lookup search 
CATEGORIES_API = YAML::load(File.open("#{RAILS_ROOT}/config/categories_api.yml"))