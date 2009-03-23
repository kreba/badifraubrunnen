class WelcomeController < ApplicationController

  def index
    flash[:notice] = 'greeting'.lc
    redirect_to( '/home' )
  end
  
end