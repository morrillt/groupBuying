class Admin::ApplicationController < ApplicationController
  # before_filter :authenticate_admin_rights!
  skip_before_filter :overall_trending
  layout 'admin'
  
  def table
    @page_limit= 25
    @start= (params[:start]||1).to_i
    @page= @start > 1 ? (@start/@page_limit)+1 : 1
    @search= params[:search]
    @order_by= params[:order_by] || "id"
    @direction= params[:direction] == "ASC" ? "DESC" : "ASC"
    @model_name= params[:model]

    model= @model_name.camelize.constantize
    @fields= model.respond_to?(:column_names) ? model.column_names : model.fields.keys
    fields_for(@model_name)                  
                                                                                                              
    if model.respond_to?(:column_names)
      @table= model.paginate(:per_page => @page_limit, :page => @page, :order => "#{@order_by} #{@direction}")
    else
      @table= model.order_by([@order_by, @direction]).paginate(:per_page => @page_limit, :page => @page)
    end                                
    
    @count= model.count
    @number_of_pages = @count / @page_limit
    respond_to do |format|
      format.html { render :partial => "admin/shared/ajax_table", :layout => false}
    end
  end

  private
  def fields_for(model)
    case model
    when 'deal'
      # Array describes what fields should be ignored/excluded
      ['id', 'deal_id', 'division_id', 'site_id', 'sold', 'updated_at'].each {|f| @fields.delete f}
    end
  end   
  
  def authenticate_admin_rights!
    unless current_user.is_a? Admin
      redirect_to root_path, :flash => {:notice => "Your need to be admin to access that page"}
    end
  end
end

# start=0&search=&order_by=sale_price&direction=DESC
