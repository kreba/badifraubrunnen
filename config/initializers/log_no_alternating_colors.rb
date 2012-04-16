# Monkey patch with the goal to output all SQL statements in the same color.

module ActiveRecord
  class LogSubscriber
    def odd?
      #@odd_or_even = !@odd_or_even
      false
    end
  end
end
