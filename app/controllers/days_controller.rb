class DaysController < ApplicationController
  
  before_filter :except => [:show, :edit, :update] do |c| c.restrict_access 'webmaster', ['a','b','c'] end
  
  # GET /weeks/1/days
  def index
    flash[:error] = 'not_available'.lc 
    redirect_to weeks_path and return false 
    
    # that is not executed:
    @week = Week.find(params[:week_id], :include => :days)
    @days = @week.days.sort_by(&:date)
  end

  # GET /weeks/1/days/new
  def new
    @day = Day.new()
  end
  
  # POST /weeks/1/days
  def create
    @day = Day.new(params[:day])
    
    if @day.save
      flash[:notice] = 'success'.lc 
      redirect_to(@day)
    else
      # validation error messages are displayed automatically
      render :action => "new"
    end
  end

  # GET /weeks/1/days/1
  def show
    @week = Week.find(params[:week_id])
    @day = Day.find(params[:id])

    if current_person.is_badiAdmin?
      @people = Person.find(:all, :order => "name").select(&:is_badiStaff?)
      @shiftinfos = Shiftinfo.find(:all, :order => "begin")
    end # TODO: refactor to edit
  end

  # PUT /weeks/1/days/1
  # PUT /weeks/1/days/1.xml
  def update
    @day = Day.find(params[:id])
    
    if @day.update_attributes(params[:day])
      flash[:notice] = 'success'.lc
      redirect_back_or_default(weeks_path)
    else
      # validation error messages are displayed automatically
      render :action => "edit"
    end
  end

end
