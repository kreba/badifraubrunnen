class TasksController < ApplicationController
  
  before_filter do |c| c.restrict_access 'webmaster' end
  cache_sweeper :week_sweeper, :only => [:imagine]

  # POST tasks/imagine
  def imagine
    Day.all.each(&:create_status_image)
    flash[:notice] = t('cache.imagine.success')
    redirect_back_or_default(weeks_path)
  end

  # POST tasks/cachesweep
  def cachesweep
    expire_fragment(/week_/) # see WeekSweeper to see what this does
    flash[:notice] = t('cache.sweep.success')
    redirect_back_or_default(weeks_path)
  end

end
