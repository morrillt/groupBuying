# TownHog appears not to display a number of coupons purchased, so we cant use it

# class TownHog < JsonImporter
#   def self.find_new_deals(&block)
#     divisions_for_import.each do |division|
#       json = JSON.parse(open(json_base_url(division.url_part)).read)
#       hash = JSON.parse(json)
#       deals = Hashie::Mash.new(hash).deal
#       
#       deals.each{ |deal| yield deal } unless deals.blank?
#       #division.update_attribute(:last_checked_at, Time.now)
#     end
#   end
#   
#   def initialize
#   end
#   
#   def self.json_base_url(division_url)
#     "http://townhog.com/api/all-deals/:division_url/json".sub(':division_url', division_url)
#   end
#   
#   def base_url
#     "http://townhog.com/coupon/"
#   end
# end