class WeeksController < ApplicationController
  
  before_filter :only => [:new, :create]  do |c| c.restrict_access 'webmaster' end
  before_filter :only => [:enable, :disable]  do |c| c.restrict_access 'admin' end
  # TODO: somehow prevent staff people from overwriting the inscription
  cache_sweeper :week_sweeper, :only => [:enable, :disable, :edit, :update, :destroy]
  
  # GET /weeks
  # GET /weeks.xml
  def index
    @saisons = current_person.all_saisons_but_mine_first
    @weeks = Week.find(:all, :order => "number")
#    @weeks = Week.find(:all, :order => "number", :include => {:days => {:shifts => :shiftinfo}})
    # :include causes "eager loading"
    @past_weeks   = @weeks.select(&:past?)
    @future_weeks = @weeks.reject(&:past?)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @weeks }
    end
  end
  
  # GET /weeks/new
  # GET /weeks/new.xml
  def new
    @week = Week.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @week }
    end
  end
  
  # POST /weeks
  # POST /weeks.xml
  def create
    @week = Week.new( params[:week] )
    
    respond_to do |format|
      if @week.save 
        flash[:notice] = t'weeks.create.success'
        format.html { redirect_to(@week) }
        format.xml  { render :xml => @week, :status => :created, :location => @week }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @week.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # GET /weeks/1
  # GET /weeks/1.xml
  def show
    @saisons = current_person.all_saisons_but_mine_first
    @week = Week.find(params[:id])
    
    if !fragment_exist? "#{@week.key_for_cache}_plans_#{current_person.roles_key_for_cache}"
      @days = @week.days.sort_by(&:date)
      @dd = WeeksHelper::WeekPlanDisplayData.for @week
    end
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @week }
    end
  end
  
  # GET /weeks/1/edit
  def edit
    @saison = Saison.find_by_name("badi")  # TODO: SUPPORT MULTIPLE SAISONS
    @admin_names = Saison.admins_by_saison[@saison.name].collect(&:name)
    @week = Week.find(params[:id])
    @people = Person.find(:all, :order => "name").select{ |p| p.is_staff_for? @saison }
  end
  
  # PUT /weeks/1
  # PUT /weeks/1.xml
  def update
    @week = Week.find(params[:id])
    
    respond_to do |format|
      if @week.update_attributes(params[:week])
        flash[:notice] = t'weeks.update.success'
        format.html { redirect_to(weeks_path) }
        #format.html { redirect_to(@week) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @week.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /weeks/1
  # DELETE /weeks/1.xml
  def destroy
    @week = Week.find(params[:id])
    @week.destroy()
    
    respond_to do |format|
      flash[:notice] = t'weeks.destroy.success'
      format.html { redirect_to(weeks_url) }
      format.xml  { head :ok }
    end
  end

  # GET /weeks/1/render_week_plan
  # TODO: replace by media-aware CSS
  def render_week_plan
    @saison = Saison.find(params[:saison_id])
    @week = Week.find(params[:id])
    @days = @week.days.sort_by(&:date)

    @dd = WeeksHelper::WeekPlanDisplayData.for @week
    @printout = true

    render( :template => 'weeks/_week_plan', :layout => 'popup', :locals => {:saison => @saison} )
  end

  # POST /weeks/1/enable
  def enable
    @week = Week.find(params[:id])
    @saison = Saison.find_by_name(params[:saison_name])

    @week.enable(@saison)
    flash[:notice] = t 'weeks.enable.success', :number => @week.number
    redirect_back_or_default(weeks_path)
  end
  # POST /weeks/1/disable
  def disable
    @week = Week.find(params[:id])
    @saison = Saison.find_by_name(params[:saison_name])

    @week.disable(@saison)
    flash[:notice] = t 'weeks.disable.success', :number => @week.number
    redirect_back_or_default(weeks_path)
  end

end
