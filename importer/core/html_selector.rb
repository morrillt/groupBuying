module HTMLSelector
  extend ActiveSupport::Concern
  
  def process_html_selectors
    hash = {}
    
    self.class.html_selectors.each do |field, selector, opts|
      next unless scraped = text_from_selector(selector, opts)
      
      self.send("#{field}=", scraped)
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
        when :address   then Proc.new { Geocoder.coordinates(inner_text) rescue nil } # FIXME: never do this
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