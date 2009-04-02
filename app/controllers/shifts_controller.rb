class ShiftsController < ApplicationController
  
  before_filter :only => :index do |c| c.restrict_access 'badiAdmin' end
  before_filter :only => [:new, :create] do |c| c.restrict_access 'webmaster' end
  before_filter :future_required, :only => [:edit, :update]

  # GET /shifts
  # GET /shifts.xml
  def index
    @shifts = Shift.find(:all, :include => [:day, :shiftinfo]).sort_by {|s| s.day.date}
    # the eager loading of days and shiftinfos reduces the amount of database accesses while rendering the list
    # (but i think does not fasten it up, because larger amounts of data are fetched)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shifts }
    end
  end

  # GET /shifts/new
  # GET /shifts/new.xml
  def new
    @week = Week.find(params[:week_id])
    @day = Day.find(params[:day_id])
    @shift = Shift.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shift }
    end
  end

  # POST /shifts
  # POST /shifts.xml
  def create
    @shift = Shift.new(params[:shift])

    respond_to do |format|
      if @shift.save
        flash[:notice] = t'shifts.create.success'
        format.html { redirect_to(@shift) }
        format.xml  { render :xml => @shift, :status => :created, :location => @shift }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shift.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /shifts/1.xml
  def show
    @shift = Shift.find(params[:id])

    respond_to do |format|
      format.xml  { render :xml => @shift }
    end
  end

  # GET /shifts/1/edit
  def edit
    @shift = Shift.find(params[:id])
    @day = @shift.day
    @week = @day.week
    
    @people = Person.find(:all, :order => "name").select(&:is_badiStaff?)
    @admin_names = Person.find(:all).select(&:is_badiAdmin?).collect(&:name).to_sentence( :connector => t('or') )
    @shiftinfos = Shiftinfo.find(:all, :order => "description DESC" )
  end

  # PUT /shifts/1
  # PUT /shifts/1.xml
  def update
    @shift = Shift.find(params[:id])
    @day = @shift.day
    @week = @day.week

    unless @shift.free? or current_person.is_badiAdmin?
      flash[:error] = t'shifts.update.already_taken'
      redirect_to :back
      return
    end

    respond_to do |format|
      if @shift.update_attributes(params[:shift])
        flash[:notice] = t'shifts.update.success'
        format.html { redirect_to( week_path(@week) ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shift.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shifts/1
  # DELETE /shifts/1.xml
  def destroy
    @shift = Shift.find(params[:id])
    @shift.destroy

    respond_to do |format|
      format.html { redirect_to(shifts_url) }
      format.xml  { head :ok }
    end
  end

  # GET /myshifts
  # GET /myshifts.xml
  def my_shifts
    @shifts = current_person.shifts.sort_by {|s| s.day.date}
#    @shifts = (Shift.find(:all).select{|s| s.person_id == current_person.id})
    logger.debug( "Numer of shifts to display for person #{current_person.name}: #{@shifts.size.to_s}" )
    
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @shifts }
    end
  end
  
  protected
    def future_required
      s = Shift.find(params[:id])
      shift_end = s.day.date + s.shiftinfo.end.seconds_since_midnight.seconds
      if shift_end < Time.now 
        flash[:error] = t'shifts.future_required.cant_change_past'
        redirect_to :back
        return false
      end
    end
end

