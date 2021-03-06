class DaysController < ApplicationController

  before_action except: [:show, :update] do |c| c.restrict_access 'webmaster' end
  cache_sweeper :week_sweeper, only: [:update]

  # GET /weeks/1/days/1
  def show
    @day ||= Day.find(params[:id])
    @week = @day.week
    @day_shifts = @day.shifts.includes(:shiftinfo).sort_by{ |shift| shift.shiftinfo.begin_plus_offset }.group_by(&:saison)

    # To render the form fields partial without displaying fields for non-existing shifts.
    # (We still want to render it because the link_to_add uses it as a template.)
    current_person.admin_saisons.each{|saison| @day_shifts[saison] ||= []}

    if current_person.has_role? 'admin'
      @people     = Saison.staff_by_saison
      @shiftinfos = Saison.shiftinfos_by_saison
    end

    # TODO: refactor to use an edit action
  end

  # PUT /weeks/1/days/1
  def update
    @day = Day.find(params[:id])

    if @day.update(day_params)
      flash[:notice] = t('days.update.success')
      redirect_back_or_default(@day.week)
    else
      # validation error messages are displayed automatically
      render action: "show"
    end
  end


  private

  def day_params
    params.require(:day).permit(:admin_remarks, shifts_attributes: [:id, :shiftinfo_id, :person_id, :_destroy])
  end

end
