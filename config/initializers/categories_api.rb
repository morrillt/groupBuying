# Yaml file contain api keys for categories lookup search 
CATEGORIES_API = YAML::load(File.open("#{Rails.root}/config/categories_api.yml"))