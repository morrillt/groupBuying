class Admin::CategoriesController < InheritedResources::Base
  layout "admin"
   # defaults :resource_class => Category, :collection_name => 'categories', :instance_name => 'category'
   before_filter :load_categories, :only => [:new, :edit]
   before_filter :init_category, :only => [:create, :update]

   def show
     @category = Category.find(params[:id])
     @matching_deals = []
     if @category.tags
       tags = @category.tags.split(',')
       match_query = tags.collect{|tag| "name LIKE '%#{tag}%'"}.join(" OR ")
       @matching_deals = Deal.includes(:categories).where(match_query).paginate(:per_page => 30, :page => params[:page] || 1)
     end
   end    
   
   def assign_to_deals
     @category = Category.find(params[:id])
     
     @deals = Deal.find_all_by_id(params[:deals])
     @deals.each{|deal|
       deal.categories << @category
       deal.save
     }
     flash[:notice] = "Successfully updated..."
     redirect_to :back
   end
   
   private
                                                   
    def init_category                  
      params[:category][:parent_id] = 0 if params[:category][:parent_id].empty?
    end
    
    def load_categories
      @base_categories = Category.where(['parent_id = 0']).collect{ |c| [c.name, c.id] } 
      # @base_categories <<  ['Top level', 0]      
    end
end
