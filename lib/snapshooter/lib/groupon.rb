module Snapshooter
  class Groupon < Base
    def initialize
      @base_url = 'http://api.groupon.com/v2'
      super
    end
  end
end