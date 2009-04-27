# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  skip_before_filter :login_required, :only => [:new, :create]
  before_filter :only => :act_as do |c| c.restrict_access 'webmaster' end

  # GET /sessions/new  (render login page)
  def new 
  end

  # POST /sessions/1  (do login)
  def create
    self.current_person = Person.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_person.remember_me unless current_person.remember_token?
        cookies[:auth_token] = { :value => self.current_person.remember_token , :expires => self.current_person.remember_token_expires_at }
      end
      flash[:notice] = t('sessions.create.access_granted')
      redirect_back_or_default(root_path)
    else
      flash.now[:error] = t('sessions.create.access_denied')
      render :action => 'new'
    end
  end

  # DELETE /sessions/1  (do logout)
  def destroy
    self.current_person.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = t('sessions.destroy.logged_out')
    redirect_to login_path
  end
  
end
