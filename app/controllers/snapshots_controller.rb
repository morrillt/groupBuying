class SnapshotsController < ApplicationController
  # GET /snapshots
  # GET /snapshots.xml
  def index
    @snapshots = Snapshot.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @snapshots }
    end
  end

  # GET /snapshots/1
  # GET /snapshots/1.xml
  def show
    @snapshot = Snapshot.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @snapshot }
    end
  end
end
