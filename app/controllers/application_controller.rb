class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  YEAR = 2016

  protect_from_forgery

  # Filters added to this controller apply to all controllers in the application.
  # Likewise, all the methods added will be available for all controllers.
  before_filter :login_required
  before_filter :set_user_language

  # include all helpers, all the time
  helper :all

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # secret: '45107402ef6b55939694954cda1a3cc8'

  def set_user_language
    # TODO: not yet implemented (environment.rb defaults to de_ch)
    # I18n.locale = current_user.language if logged_in?
  end

  def restrict_access( role_name )
    saison_if_given = Saison.find_by_name(params[:saison_name])
    unless current_person.has_role? role_name, saison_if_given
      role_descr = t('role.' + (saison_if_given ? params[:saison_name] + role_name.capitalize : role_name))
      flash[:error] = t('application.access_restricted', role: role_descr)
      redirect_back_or_default( home_path ) and return false
    end
  end

#  # example: restrict_access 'a', ['b', 'c']
#  # is interpreted as: the person must have roles  a and (b or c)
#  def restrict_access( *needed_role_sets )
#    person_is_authorized = needed_role_sets.all? {|role_set| role_set.any? {|role| current_person.has_role? role }}
#    unless person_is_authorized
#      flash[:error] = t('application.access_restricted', role: sentence(needed_role_sets))
#      redirect_back_or_default( '/home' ) and return false
#    end
#  end
#
#  def sentence( role_arrays )
#    single_role = role_arrays
#    t("role.#{single_role}")
## TO DO: adapt to multiple roles as documented above
##    role_arrays.collect {|role_set|
##      if role_set.to_a.size > 1
##        "(" + role_set.collect{|r| I18n.t(r.name)}.to_sentence( connector: I18n.t('or') ) + ")"
##      elsif
##        I18n.t(role_set.first.name)
##      end
##    }.to_sentence( connector: I18n.t('and') )
#  end
end
