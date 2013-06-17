class Week < ActiveRecord::Base
  # Authorization plugin
  acts_as_authorizable #Why???

  has_many :days
  # has_many :shifts, through: :days # unused
  belongs_to :person  #Wochenverantwortliche/r

  before_validation :assign_7_days, on: :create
  after_destroy :destroy_all_days

  validates_size_of    :days, is: 7, message: 'wrong_number_(expecting_{{count}})'
  validates_associated :days
  validates_presence_of     :number, on: :create
  validates_uniqueness_of   :number, on: :create
  validates_numericality_of :number, on: :create, only_integer: true, greater_than: 0, less_than_or_equal_to: 52

  #attr_accessible :person
  #attr_readonly :number, :days

  # returns all days, monday first
  def weekdays
    days.sort_by{ |day| day.date }
  end
  
  def past?
    return Date.commercial( ApplicationController.year , self.number , 7 ) < Date.today;    
  end

  def enabled?( saison )
    self.enabled_saisons.split(Week.enabled_saisons_delimiter).include? saison.id.to_s
  end
  def enable( saison )
    old = self.enabled_saisons.split(Week.enabled_saisons_delimiter)
    new = (old | [saison.id.to_s]).join(Week.enabled_saisons_delimiter)
    self.update_attribute(:enabled_saisons, new)
    self.all_shifts( saison ) { |shift| shift.enabled = true }
  end
  def disable( saison )
    old = self.enabled_saisons.split(Week.enabled_saisons_delimiter)
    new = (old - [saison.id.to_s]).join(Week.enabled_saisons_delimiter)
    self.update_attribute(:enabled_saisons, new)
    self.all_shifts( saison ) { |shift| shift.enabled = false }
  end
  def self.enabled_saisons_delimiter
    ','
  end


  protected

  def all_shifts( saison ) #expecting a block
    shifts = self.days.collect{|day| day.find_shifts_by_saison(saison)}.flatten
    shifts.each{ |shift| yield(shift) }
    shifts.all?(&:save)
  end
  

  private

  def assign_7_days
    @year = ApplicationController.year
    logger.debug( "(II) Creating 7 days for week #{self.number} in year #{@year}:" )
    for wday in 1..7
      @date = Date.commercial( @year , self.number , wday )
      logger.debug( "(II)   Day #{wday}:  #{@date.strftime( "%d.%m." )}" )
      self.days << (Day.find_by_date( @date ) || Day.create( date: @date ))
    end
  end

  def destroy_all_days
    self.days.each(&:destroy)
  end

end
