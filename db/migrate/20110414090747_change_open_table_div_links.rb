class ChangeOpenTableDivLinks < ActiveRecord::Migration
  def self.up
    Site.find_by_source_name('open_table').divisions.each{|d|
      match_data = d.url.match(/(http:\/\/spotlight.opentable.com).*?(\/[a-z\-]*)$/)
      unless match_data.nil?
        d.url = match_data[1] + '/city' + match_data[2]
        d.save
      end
    }
  end

  def self.down
    
  end
end
