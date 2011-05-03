class Admin::CategoriesController < InheritedResources::Base
  layout "admin"
   # defaults :resource_class => Category, :collection_name => 'categories', :instance_name => 'category'
   before_filter :load_categories, :only => [:new, :edit]
   
   
   private
   
    def load_categories
      @base_categories = Category.where(['parent_id = 0']).collect{ |c| [c.name, c.id] } 
      # @base_categories <<  ['Top level', 0]      
    end
end
