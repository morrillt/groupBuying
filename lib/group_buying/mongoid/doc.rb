module GroupBuying
  module Mongoid
    module Doc
      extend ActiveSupport::Concern
      include ::Mongoid::Document
      include ::Mongoid::Timestamps
      
      module ClassMethods
        # TODO: how about move this to time class? is it the same for any JS, or mongo-specific?
        def convert_time_to_json(time)
          ltime = time.localtime # for some mongo reason we need to convert to local
          "new Date(#{ltime.year}, #{ltime.month - 1}, #{ltime.day}, #{ltime.hour}, #{ltime.min})"
        end
        
        def js_time_query(operator, fields)
          query = fields.map{|field, value| "this.#{field} #{operator} #{convert_time_to_json(value)}" }.join(" && ")
          "function() {return #{query}}"
        end
        
        def time_gt_than(fields = {})
          js_time_query '>=', fields
        end

        def time_lt_than(fields = {})
          js_time_query '<=', fields
        end
      end
    end
  end
end