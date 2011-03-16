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
    raw_data.each{|line| Nokogiri::HTML(line) }
  end
  
  def raw_data
    return unless deal_exists?
    @raw_data ||= cached? ? current_snapshot.raw_data : load_url
  end
  
  def location
    @location.try(:call)
  end
end