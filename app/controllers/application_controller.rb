class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  # Filters added to this controller apply to all controllers in the application.
  # Likewise, all the methods added will be available for all controllers.
  before_filter :login_required
  before_filter :set_user_language
  # This averts plain text logging of password-related parameters (does not influence SQL logging!)
  filter_parameter_logging "password"
  
  # include all helpers, all the time
  helper :all 

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '45107402ef6b55939694954cda1a3cc8'

  def set_user_language
    'de'
    #I18n.locale = current_user.language if logged_in?
  end

  def ApplicationController.year
    return 2008
  end
  
  # example: restrict_access 'a', ['b', 'c']
  # is interpreted as: the person must have roles  a and (b or c)
  def restrict_access( *needed_role_sets )
    person_is_authorized = needed_role_sets.all? {|role_set| role_set.any? {|role| current_person.has_role? role }}
    unless person_is_authorized
      flash[:error] = 'access_restricted'.lc :role => l_sentence( needed_role_sets )
      redirect_back_or_default( '/home' ) and return false
    end
  end
  
  def l_sentence( role_arrays )
    role_arrays.collect {|role_set| 
      if role_set.to_a.size > 1
        "(" + role_set.collect(&:l).to_sentence( :connector => 'or'.l ) + ")"
      elsif
        role_set.first.l
      end
    }.to_sentence( :connector => 'and'.l )
  end
end
