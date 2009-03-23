class HelpController < ApplicationController
  skip_before_filter :login_required
  
  # GET /contact
  def contact
    people = Person.find(:all)
    @badi_admins  = people.select(&:is_badiAdmin?)
    @kiosk_admins = people.select(&:is_kioskAdmin?)
    @webmasters   = people.select(&:is_webmaster?)
  end
  
end