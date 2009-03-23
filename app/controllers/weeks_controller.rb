class WeeksController < ApplicationController
  
  before_filter :only => [:new, :create] do |c| c.restrict_access 'webmaster' end
  
  # GET /weeks
  # GET /weeks.xml
  def index
    @weeks = Week.find(:all, :order => "number", :include => {:days => {:shifts => :shiftinfo}})
    # :include causes "eager loading"
    @past_weeks   = @weeks.select(&:past?)
    @future_weeks = @weeks.select{|w| !w.past?}
    
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
    @week = Week.create( params[:week] )
    
    respond_to do |format|
      if @week.save 
        flash[:notice] = 'success'.lc
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
    @week = Week.find(params[:id])
    @days = @week.days.sort_by(&:date)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @week }
    end
  end
  
  # GET /weeks/1/edit
  def edit
    @week = Week.find(params[:id])
    @people = Person.find(:all, :order => "name").select(&:is_badiStaff?)
  end
  
  # PUT /weeks/1
  # PUT /weeks/1.xml
  def update
    @week = Week.find(params[:id])
    
    respond_to do |format|
      if @week.update_attributes(params[:week])
        flash[:notice] = 'success'.lc
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
      flash[:notice] = 'success'.lc
      format.html { redirect_to(weeks_url) }
      format.xml  { head :ok }
    end
  end

  # GET /weeks/1/render_week_plan
  # TODO: replace by media-aware CSS
  def render_week_plan
    @week = Week.find(params[:id])
    @days = @week.days.sort_by(&:date)
    
    @printout = true
    render( :template => 'weeks/_week_plan', :layout => 'popup' )
  end

end
