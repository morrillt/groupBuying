class HTMLSnapshooter < BaseSnapshooter
  include HTMLSelector
  
  # just does HEAD request and checks for 200
  def existence_check
    uri = URI.parse(url)
    req = Net::HTTP.new(uri.host, uri.port)
    res = req.request_head(uri.path)

    res.code == '200'
  end
  
  def parse!
    return if @parsed
    process_html_selectors if deal_exists?
    @parsed = true
  end
  
  def doc
    @doc ||= parse_doc
  end
  
  def parse_doc
    Nokogiri::HTML(raw_data)
  end
  
  def raw_data
    return unless deal_exists?
    
    cached? ? current_snapshot.raw_data : load_url
  end
  
  def location
    @location.try(:call)
  end
  
  def load_url
    begin
      open(url).read
    rescue Timeout::Error => e
      Rails.logger.info "[IMPORT ERROR]: " + e.inspect
      nil
    end
  end
end