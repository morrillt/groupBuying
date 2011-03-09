module HTMLSelector
  extend ActiveSupport::Concern
  
  def process_html_selectors
    hash = {}
    
    self.class.html_selectors.each do |field, selector, opts|
      next unless scraped = text_from_selector(selector, opts)
      hash[field] = scraped
    end
    
    hash
  end
  
  # load the inner text from the first node matching this selector
  def text_from_selector(selector, opts = {})
    node = doc.search(selector).send(opts[:node] || :first)
    
    if node
      node = node.attributes[opts[:attr]] if opts[:attr]
      inner_text = node.inner_text.strip
      
      case opts[:type]
        when :number    then inner_text[/[\d\.]+/].to_f
        when :address   then Geocoder.coordinates(inner_text)
        when :raw       then node
        else            inner_text
      end
    end
  end
  
  module ClassMethods
    def html_selectors
      @html_selectors
    end
        
    def html_selector(field, selector, opts = {})
      #puts "setting #{field} = #{selector}"
      @html_selectors ||= []
      @html_selectors << [field, selector, opts]
    end
  end
end

class UrlImporter < BaseImporter
  include HTMLSelector
  
  def deal_exists?
    if @deal_exists.nil?
      @exists = cached? ? current_snapshot.deal_exists? : existence_check
    else
      @deal_exists
    end
  end
  
  def parse
    if deal_exists?
      @attributes = process_html_selectors
      super
    end
  end
  
  # just does HEAD request and checks for 200
  def existence_check
    uri = URI.parse(url)
    req = Net::HTTP.new(uri.host, uri.port)
    res = req.request_head(uri.path)
    
    res.code == '200'
  end
  
  def parse_doc
    Nokogiri::HTML(raw_data)
  end
  
  def raw_data
    return unless deal_exists?
    
    cached? ? current_snapshot.raw_data : load_url
  end
  
  def load_url
    open(url).read
  end
  
  # FIXME: ugly, it's here so sub-class can just set discount/discount_text and we'll calculate the value
  def value
    @value || respond_to?(:discount) ? (price.to_i / discount.to_f * 100) : nil
  end
end