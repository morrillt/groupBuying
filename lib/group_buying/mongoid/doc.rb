module GroupBuying
  module Mongoid
    module Doc
      extend ActiveSupport::Concern
      include ::Mongoid::Document
      include ::Mongoid::Timestamps
      
      module ClassMethods
        # need this because MetaWhere and Mongoid conflict on :created_at.desc
        # this is a hack for now
        # mcc :created_at, :desc, 1.hour.ago == {:created_at.desc => 1.hour.ago}
        def mcc(key, operator, value)
          mcc_field = ::Mongoid::Criterion::Complex.new(:key => key, :operator => operator)
          { mcc_field => value }
        end
      end
    end
  end
end