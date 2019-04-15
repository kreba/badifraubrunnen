class TasksController < ApplicationController
  
  before_action do |c| c.restrict_access 'webmaster' end

  # POST tasks/cachesweep
  def cachesweep

    # expire_fragment(/week_/) # I'd love to do that, but Memcache does not support it (must use Memcache on Heroku); see WeekSweeper
    Week.all.each(&:touch)

    flash[:notice] = t('cache.sweep.success')
    redirect_back_or_default(weeks_path)
  end

end
