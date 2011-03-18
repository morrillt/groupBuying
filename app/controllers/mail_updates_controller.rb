class MailUpdatesController < ApplicationController

  def new
    @mail_update = MailUpdate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mail_update }
    end
  end
  
  def show
  end

  def create
    @mail_update = MailUpdate.new(params[:mail_update])

    respond_to do |format|
      if @mail_update.save
        format.html { redirect_to(@mail_update, :notice => 'Mail Update was successfully created.') }
        format.xml  { render :xml => @mail_update, :status => :created, :location => @mail_update }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mail_update.errors, :status => :unprocessable_entity }
      end
    end
  end

end
