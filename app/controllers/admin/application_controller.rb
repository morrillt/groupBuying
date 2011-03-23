class Admin::ApplicationController < ApplicationController
  def table
    @start= params[:start]||0
    @search= params[:search]
    @order_by= params[:order_by] || "id"
    @direction= params[:direction] || "ASC"
    @model_name= params[:model]

    model= Object.const_get(@model_name.capitalize)
    @fields= model.column_names
    fields_for(@model_name)
    @page_limit= 25
    @table = model.paginate(:per_page => @page_limit, :page => (params[:page] || 1))
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
      # Array describes what fields should be ignored
      ['id', 'deal_id', 'division_id', 'site_id', 'sold', 'updated_at'].each {|f| @fields.delete f}
    end
  end
end

start=0&search=&order_by=sale_price&direction=DESC
