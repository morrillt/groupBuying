module HTMLSelector
  extend ActiveSupport::Concern
  
  def html_selectors
    @html_selectors ||= begin
      hash = {}
      
      self.class.html_selectors.each do |field, selector, opts|
        next unless scraped = text_from_selector(selector, opts)
        
        instance_variable_set("@#{field}", scraped)
        hash[field] = scraped
      end
      
      hash
    end
  end
  
  # load the inner text from the first node matching this selector
  def text_from_selector(selector, opts = {})
    node = doc.search(selector).send(opts[:node] || :first)
    
    if node
      inner_text = node.inner_text.strip
      
      case opts[:type]
        when :number    then inner_text[/[\d\.]+/]
        when :address   then Geocoder.coordinates(inner_text)
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
  
  def cached?
    !! current_snapshot
  end
  
  def current_snapshot
    @current_snapshot ||= Snapshot.current.where(:url => url).first
  end
  
  def exists?
    if @exists.nil?
      @exists = cached? ? true : existence_check
    else
      @exists
    end
  end
  
  # just does HEAD request and checks for 200
  def existence_check
    uri = URI.parse(url)
    req = Net::HTTP.new(uri.host, uri.port)
    res = req.request_head(uri.path)
    
    res.code == '200'
  end
  
  def doc
    @doc ||= Nokogiri::HTML(html) if exists?
  end
  
  def html
    cached? ? current_snapshot.raw_data : load_url
  end
  
  def load_url
    open(url)
  end
  
  def attributes
    @attrs ||= html_selectors
  end
  
  # FIXME: ugly, it's here so sub-class can just set discount/discount_text and we'll calculate the value
  def value
    @value || respond_to?(:discount) ? (price.to_i / discount.to_f * 100) : nil
  end
end