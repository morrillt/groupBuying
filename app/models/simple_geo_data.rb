require 'lib/simple_geo_script/simple_geo'


class SimpleGeoData < ActiveRecord::Base
  def test_data
    sg =  SimpleGeo::SimpleGeoCollector.new
    deals = Deal.find(:all, :select => 'raw_address', :limit => 100)
    init = Time.now
    fails = 0
    error = 0
    winning = 0
    for d in deals do
      begin
        h = sg.parsing d.raw_address
        r = sg.search h
        if r.nil?
          fails += 1
        else
          winning +=1
        end
        
      rescue
        error +=1
      end
    end    

    puts "time:#{((Time.now)-init)/60} mins success:#{winning} fails:#{fails} error:#{error}"
  end
end
