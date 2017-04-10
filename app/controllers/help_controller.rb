class HelpController < ApplicationController
  skip_before_filter :login_required

  # GET /contact
  def contact
    @admins = Saison.admins_by_saison
    @webmasters = Person.having_role 'webmaster'
  end

end
