class Admin::DealCategoriesController < Admin::ApplicationController
  layout "admin"
  
  def index
    @deal = Deal.find(params[:deal_id])
    @sub_categories = Category.all.group_by(&:parent_id)
    @categories = @sub_categories.delete(0)
    @base_categories = Category.where(['parent_id = 0']).collect{ |c| [c.name, c.id] } 
    @base_categories <<  ['Top level', 0]
  end                                       
  
  def update    
    @deal = Deal.find(params[:deal_id])
    params[:deal][:category_ids] = params[:deal][:category_ids].collect(&:to_i)
    
    @deal.categories.each{|cat|    
      unless params[:deal][:category_ids].include?(cat.id)
        @deal.categories.delete(cat)          
      end     
      params[:deal][:category_ids] -= [cat.id]
    } 
    Category.find_all_by_id(params[:deal][:category_ids]).each{|cat|
      @deal.categories << cat
    }                  
    
    if params[:new_category][:name] && !params[:new_category][:name].empty?
      new_cat = Category.create(:name => params[:new_category][:name], :parent_id => params[:new_category][:parent_id])
      @deal.categories << new_cat
    end
    
    if @deal.save 
      flash[:notice] = "Successfully updated..."
      # Redirect to next uncategorized item
    else
      flash[:error] = "Error occured during update..."
      redirect_to :back
    end
    
  end
end
