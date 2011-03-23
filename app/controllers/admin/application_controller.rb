class Admin::ApplicationController < ApplicationController
  def table
    @page_limit= 25
    @start= (params[:start]||1).to_i
    @page= @start > 1 ? (@start/@page_limit)+1 : 1
    @search= params[:search]
    @order_by= params[:order_by] || "id"
    @direction= params[:direction] == "ASC" ? "DESC" : "ASC"
    @model_name= params[:model]

    model= Object.const_get(@model_name.capitalize)
    @fields= model.column_names
    fields_for(@model_name)
    @table= model.paginate(:per_page => @page_limit, :page => @page, :order => "#{@order_by} #{@direction}")
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
end

# start=0&search=&order_by=sale_price&direction=DESC
