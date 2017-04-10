class WelcomeController < ApplicationController

  def index
    flash[:notice] = t('welcome.greeting', person_name: current_person.name)
    redirect_to home_path
  end

end
