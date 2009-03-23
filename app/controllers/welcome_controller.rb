class WelcomeController < ApplicationController

  def index
    flash[:notice] = t'welcome.index.greeting'
    redirect_to( '/home' )
  end
  
end