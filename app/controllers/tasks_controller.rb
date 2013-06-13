class TasksController < ApplicationController
  
  before_filter do |c| c.restrict_access 'webmaster' end

  # Hmm, no record gets saved during #imagine, so where is the point in adding the cache sweeper here?
  #  Shouldn't I rather touch all weeks manually? (since I switched to updated-at-based cache keys)
  cache_sweeper :week_sweeper, :only => [:imagine] 

  # Deprecated. Heroku has a read-only file system. 
  # In order for this to make sense again, I'd have to switch to static asset caching (stores the generated images in runtime memory; Rails app serves them itself; not recommended in production).
  # POST tasks/imagine
  def imagine
    Day.all.each(&:create_status_image)
    flash[:notice] = t('cache.imagine.success')
    redirect_back_or_default(weeks_path)
  end

  # POST tasks/cachesweep
  def cachesweep

    # expire_fragment(/week_/) # I'd love to do that, but Memcache does not support it (must use Memcache on Heroku); see WeekSweeper
    Week.all.each(&:touch)

    flash[:notice] = t('cache.sweep.success')
    redirect_back_or_default(weeks_path)
  end

end
