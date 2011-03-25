require 'lib/simple_geo_script/simple_geo'
class SimpleGeoData < ActiveRecord::Base

  def test_ind_data deal
    sg =  SimpleGeo::SimpleGeoCollector.new
    init = Time.now
    fails = 0
    error = 0
    winning = 0
    begin
      h = sg.parsing deal
      r = sg.search h
      if r.nil? 
        puts "#{deal.id} fails"
        fails += 1
      else
        puts "#{deal.id} wins"
        winning += 1
      end
    rescue
      puts "#{deal.id} died"
      error +=1
    end
    puts "time: #{((Time.now)-init)/60} mins success:#{winning} fails:#{fails} error:#{error}"
  end

  def test_data
    sg =  SimpleGeo::SimpleGeoCollector.new
    deals = Deal.find(:all, :select => 'id,raw_address,telephone')
    init = Time.now
    fails = 0
    error = 0
    winning = 0
    for deal in deals
      begin
        h = sg.parsing deal
        r = sg.search h
        if r.nil? 
          puts "#{deal.id} fails"
          fails += 1
        else
          puts "#{deal.id} wins"
          winning += 1
        end
      rescue
        puts "#{deal.id} died"
        error +=1
      end
    end
    puts "time: #{((Time.now)-init)/60} mins success:#{winning} fails:#{fails} error:#{error}"
  end
end
