require 'lib/simple_geo_script/simple_geo'
class SimpleGeoData < ActiveRecord::Base
  def test_data
    sg =  SimpleGeo::SimpleGeoCollector.new
    deals = Deal.find(:all,:limit => 50)
    puts "deals: #{deals.size}"
    init = Time.now
    fails = 0
    error = 0
    winning = 0
    numbers = Array.new
    for deal in deals
      begin        
        h = sg.parsing deal
        r = sg.search h
        numbers.push r
      rescue
        error +=1
      end
    end
    return numbers
    # zero = 0
    # one = 0
    # many = 0
    # puts numbers.inspect
    # for i in numbers
    #   if i==0
    #     zero += 1
    #   elsif i == 1
    #     one += 1        
    #   else
    #     many += 1
    #   end      
    # end
    # puts "zero #{zero/numbers.length}, one: #{one/numbers.length}, many: #{many/numbers.length}"
  end

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
end
