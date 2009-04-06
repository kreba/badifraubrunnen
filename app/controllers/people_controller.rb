class PeopleController < ApplicationController
  
  # Do not allow anyone to subscribe by themselfes
  #skip_before_filter :login_required, :only => [:new, :create]
  before_filter :except => [:edit, :find_location, :index, :update] do |c| c.restrict_access 'admin' end
  
  # GET /people
  def index
    @people = Person.find(:all, :order => "name").select{ |p| p.has_role? 'staff'}
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
    @person = Person.new(params[:person])
    for role in current_person.roles.select {|r| r.name.include?('Admin') } 
      @person.has_role role.name.gsub('Admin','Staff')
    end
    
    if @person.save
      flash[:notice] = t'people.create.success'
      self.current_person = @person unless logged_in? # admin can create people without losing his login
      redirect_back_or_default(people_path)
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @person = Person.find(params[:id])
    @person.destroy
    redirect_back_or_default(people_path)
  end

  # GET /shiftinfos/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  # PUT /people/1
  def update
    @person = Person.find(params[:id])

    if @person.update_attributes(params[:person])
      flash[:notice] = t'people.update.success'
      render :action => "edit" #pointing there on purpose
    else
      render :action => "edit"
    end
  end

  # GET /people/find_location  (used in ajax call)
  def find_location
    @location = PeopleHelper.fetch_location_by_postal_code(params[:zip])

    if @location.nil? or @location.empty?
      render :nothing => true
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

end
