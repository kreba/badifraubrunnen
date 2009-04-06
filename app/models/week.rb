class Week < ActiveRecord::Base
  # Authorization plugin
  acts_as_authorizable

  has_many :days
  belongs_to :person  #Wochenverantwortliche/r

  before_validation_on_create :assign_7_days
  after_destroy :destroy_all_days

  validates_size_of    :days, :is => 7, :message => 'wrong_number_(expecting_{{count}})'
  validates_associated :days
  validates_presence_of     :number, :on => :create
  validates_uniqueness_of   :number, :on => :create
  validates_numericality_of :number, :on => :create, :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 52

  #attr_accessible :person
  #attr_readonly :number, :days

  def weekdays
    # can contain nil values
    return (1..7).collect{|wday| self.weekday wday}
  end
  
  def weekday( wday )
    # return value can be nil, if no such day exists in the database
    return self.days.detect{|d| d.date.wday == wday % 7 }
  end
  
  def past?
    return Date.commercial( ApplicationController.year , self.number , 7 ) < Date.today;    
  end
  
  private
    def assign_7_days
      @year = ApplicationController.year
      logger.debug( "(II) Creating 7 days for week #{self.number} in year #{@year}:" )
      for wday in 1..7
        @date = Date.commercial( @year , self.number , wday )
        logger.debug( "(II)   Day #{wday}:  #{@date.strftime( "%d.%m." )}" )
        self.days << (Day.find_by_date( @date ) || Day.create( :date => @date ))
      end
    end

    def destroy_all_days
      self.days.each(&:destroy)
    end
end
