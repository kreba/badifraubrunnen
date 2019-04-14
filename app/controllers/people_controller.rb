class PeopleController < ApplicationController

  # Do not allow anyone to subscribe by themselfes
  #skip_before_action :login_required, only: [:new, :create]
  before_action except: [:edit, :find_location, :index, :update] do |c| c.restrict_access 'admin' end

  # GET /people
  def index
    @people = Person.order('name')

    @csv_attributes = %w[ name address postal_code location phone phone2 email preferences roles_str ]
    @csv_delimiter  = ';'
  end

  # GET /people/new
  def new
    @person = Person.new()
  end

  # POST /people/create
  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with request forgery protection.
    # uncomment at your own risk
    # reset_session
    @person = Person.new(person_params)
    update_staff_roles(@person)
    if @person.save
      flash[:notice] = t'people.create.success'
      self.current_person = @person unless logged_in? # admin can create people without losing his login
      redirect_back_or_default(people_path)
    else
      render action: 'new'
    end
  end

  def destroy
    @person = Person.find(params[:id])

    if @person.is_webmaster?
      flash[:error] = t'people.destroy.webmaster_cannot_be_deleted_by_admin'
    else
      @person.destroy
      flash[:notice] = t('people.destroy.success', person_name: @person.name)
    end

    redirect_back_or_default(people_path)
  end

  # GET /shiftinfos/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  # PUT /people/1
  def update
    @person = Person.find(params[:id])
    update_staff_roles(@person)
    if @person.update(person_params)
      flash[:notice] = t'people.update.success'
      render action: "edit" #pointing there on purpose
    else
      render action: "edit"
    end
  end

  # GET /people/find_location  (used in ajax call)
  def find_location
    @location = PeopleHelper.fetch_location_by_postal_code(params[:zip])

    if @location.blank?
      render nothing: true
    else
      render :update do |page|
        page["person_location"].setValue( @location )
      end
    end
  end

  # PUT /people/1/set_roles
  # What is this method good for?
#  def act_as_various # TODO: make GUI
#    current_person.is_webmaster? || redirect_to( login_path ) and return false
#    render :update do
#      for role in "badiAdmin badiStaff kioskAdmin kioskStaff".split(' ') # TODO: automatically find all by DOM
#        if page["toggle_"+role].value
#          current_person.has_role role
#        else
#          current_person.has_no_role role
#        end
#      end
#    end
#  end


  private

  def staff_roles
    Role.where(name: 'staff').order(:id)
  end
  helper_method :staff_roles

  def update_staff_roles(person)
    staff_role_ids = staff_roles.map{ |r| r.id.to_s }
    role_ids = person.role_ids.map(&:to_s)

    role_params.each do |role_id, checked|
      if staff_role_ids.include?(role_id)
        if checked == '1'
          role_ids << role_id unless role_ids.include? role_id
        else
          role_ids.delete role_id
        end
      end
    end

    person.role_ids = role_ids
  end

  def person_params
    params[:person] ||= {}
    params[:person].permit(
        :name, :login, :phone, :phone2, :address, :postal_code, :location,
        :email, :preferences, :password, :password_confirmation, :brevet
    )
  end

  def role_params
    params[:person] ||= {}
    params[:person][:roles] || {}
  end

end
