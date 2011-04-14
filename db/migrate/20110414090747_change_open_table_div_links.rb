class ChangeOpenTableDivLinks < ActiveRecord::Migration
  def self.up
    Site.find(4).divisions.each{|d|
      match_data = d.url.match(/(http:\/\/spotlight.opentable.com).*?(\/[a-z\-]*)$/)
      d.url = match_data[1] + '/city' + match_data[2]
      d.save
    }
  end

  def self.down
    
  end
end
