class WelcomeController < ApplicationController

  def index
    flash[:notice] = t'welcome.greeting'
    redirect_to( '/home' )
  end
  
end