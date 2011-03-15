class UsersController < InheritedResources::Base
  
  def new
    @user = User.new
    render :layout => false
  end

  def create
    @user = User.new(params[:user])
    redirect_to root_path if @user.save      
  end

end
