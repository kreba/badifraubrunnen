class DaysController < ApplicationController
  
  before_filter :except => [:show, :edit, :update] do |c| c.restrict_access 'webmaster' end
  
  # GET /weeks/1/days
  def index
    flash[:error] = t'days.index.not_available'
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
      flash[:notice] = t'days.create.success'
      redirect_to(@day)
    else
      # validation error messages are displayed automatically
      render :action => "new"
    end
  end

  # GET /weeks/1/days/1
  # TODO: ATTENTION: people that are admin for any saison should not be staff
  #       for any other saison, since they can't subscribe to such shifts...
  def show
    @day = Day.find(params[:id])
    @week = @day.week
    @day_shifts = @day.shifts.group_by(&:saison)

    if current_person.has_role? 'admin'
      @people     = Saison.staff_by_saison
      @shiftinfos = Saison.shiftinfos_by_saison
    end # TODO: refactor to edit
  end

  # PUT /weeks/1/days/1
  # PUT /weeks/1/days/1.xml
  def update
    @day = Day.find(params[:id])
    
    if @day.update_attributes(params[:day])
      flash[:notice] = t('days.update.success')
      redirect_back_or_default(weeks_path)
    else
      # validation error messages are displayed automatically
      render :action => "edit"
    end
  end

end
