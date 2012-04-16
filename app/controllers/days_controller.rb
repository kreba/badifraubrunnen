class DaysController < ApplicationController
  
  before_filter :except => [:show, :edit, :update] do |c| c.restrict_access 'webmaster' end
  cache_sweeper :week_sweeper, :only => [:update]
  
  # GET /weeks/1/days
  def index
    flash[:error] = t('days.index.not_available')
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
      flash[:notice] = t('days.create.success')
      redirect_to(@day)
    else
      # validation error messages are displayed automatically
      render :action => "new"
    end
  end

  # GET /weeks/1/days/1
  def show
    @day = Day.find(params[:id])
    @week = @day.week
    @day_shifts = @day.shifts(include: :shiftinfo).group_by(&:saison)
    @day_shifts.each{|saison, shifts| shifts.sort_by!{|shift| shift.shiftinfo.begin} }

    # To render the form fields partial without displaying fields for non-existing shifts.
    # (We still want to render it because the link_to_add uses it as a template.)
    current_person.admin_saisons.each{|saison| @day_shifts[saison] ||= []}

    if current_person.has_role? 'admin'
      @people     = Saison.staff_by_saison
      @shiftinfos = Saison.shiftinfos_by_saison
    end # TODO: refactor to edit
  end

  # PUT /weeks/1/days/1
  def update
    @day = Day.find(params[:id])
    
    if @day.update_attributes(params[:day])
      flash[:notice] = t('days.update.success')
      redirect_back_or_default(@day.week)
    else
      # validation error messages are displayed automatically
      render :action => "edit"
    end
  end

end
