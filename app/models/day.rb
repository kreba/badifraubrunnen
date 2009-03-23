class Day < ActiveRecord::Base
  before_validation_on_create :assert_3_shifts
  after_destroy :destroy_all_shifts
  
  belongs_to :week
  has_many :shifts

  # Authorization plugin
  acts_as_authorizable
  
  #attr_accessible :updated_at
  #attr_readonly :created_at

  validates_size_of    :shifts, :is => 3
  validates_associated :shifts
  validates_presence_of :date
  
  def shift_attributes=(attrs) # (invoked on an update (that is, on submitting an update form))
    # assert existance
    self.shifts.update(attrs.keys, attrs.values)
  end
  
  def status_image_path
    "/images/#{shifts_str}.png"  #TODO: auto-generate image if not available
  end
  
  def date_str fmt = '%A %d.%m.%Y'
    return self.date.strftime( fmt )
  end

  def yesterday
    return Day.find_by_date( self.date.yesterday );
  end

  def tomorrow
    return Day.find_by_date( self.date.tomorrow );
  end

  private
    def shifts_str
      return (self.shifts.sort_by {|s| s.shiftinfo.begin}).inject('') { 
             |str, shift| str << (shift.free? ? '1' : '0') }
    end

    def assert_3_shifts
      if self.shifts.size != 3
        if self.shifts.size == 0 
          logger.info( '(II)   Creating 3 shifts for day '<< self.date.strftime( "%d.%m." ) )
          for i in 1..3 
            self.shifts << Shift.create( :shiftinfo_id => i ) 
          end
        else
          errors.add_to_base(I18n.translate'day.assert_3_shifts.wrong_number')
          return false
        end
      end
    end

    def destroy_all_shifts
      self.shifts.each { |shift| shift.destroy() }
    end
  
end
