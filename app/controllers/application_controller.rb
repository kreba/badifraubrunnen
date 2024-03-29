class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  # Filters added to this controller apply to all controllers in the application.
  # Likewise, all the methods added will be available for all controllers.
  before_action :login_required
  before_action :set_user_language

  # include all helpers, all the time
  helper :all

  def set_user_language
    # TODO: not yet implemented (environment.rb defaults to de_ch)
    # I18n.locale = current_user.language if logged_in?
  end

  def restrict_access( role_name_or_array )
    saison_if_given = Saison.find_by name: params[:saison_name]
    unless current_person.has_role? role_name_or_array, saison_if_given
      role_descr = [*role_name_or_array].map do |role_name|
        t('role.' + (saison_if_given ? params[:saison_name] + role_name.capitalize : role_name))
      end.join(' ' + t('or') + ' ')
      flash[:error] = t('application.access_restricted', role: role_descr)
      redirect_back_or_default( home_path ) and return false
    end
  end

end
