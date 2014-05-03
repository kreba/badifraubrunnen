class Saison < ActiveRecord::Base
  # Authorization plugin
  acts_as_authorizable

  has_many :shiftinfos

  validates_presence_of :begin, :end, :name
  validates_uniqueness_of :name

  attr_accessible :begin, :end
  attr_readonly :name

  def <=> other
    self.name <=> other.name
  end

  def color # move this information to the database?
    case name
    when 'badi'
      'rgba( 38, 158,   0, 0.5)'
    when 'kiosk'
      'rgba(255, 255,   0, 0.5)'
    end
  end

  def badi?
    name == 'badi'
  end
  def kiosk?
    name == 'kiosk'
  end
  def self.badi
    find_by_name('badi')
  end
  def self.kiosk
    find_by_name('kiosk')
  end

  def self.daytime_limits
      times = Shiftinfo.all
      min = times.sort_by(&:begin).first.begin.seconds_since_midnight
      max = times.sort_by(&:end).last.end.seconds_since_midnight
    return min, max
  end
  def daytime_limits
    times = self.shiftinfos
    min = times.sort_by(&:begin).first.begin.seconds_since_midnight
    max = times.sort_by(&:end).last.end.seconds_since_midnight
    return min, max
  end

  def self.shiftinfos_by_saison( shiftinfos = Shiftinfo.includes(:saison).to_a )
    shiftinfos.sort_by!(&:begin_plus_offset)
    hash_by_saison(shiftinfos){ |shiftinfo, saison|
      shiftinfo.saison.eql? saison
    }
  end
  def self.staff_by_saison( people = Person.all(order: 'name') )
    people_by_saison_for_role('staff', people)
  end
  def self.admins_by_saison( people = Person.all(order: 'name') )
    people_by_saison_for_role('admin', people)
  end

  #see README_FOR_APP for instructions how to set up a saison
  def self.long_days
    high_saison = Day.all(include: :week).select{ |day| (25..35).include?(day.week.number) }
    week_end    = Day.all.select{ |day| %w'Sat Sun'.include? day.date.strftime( '%a' ) }

    high_saison | week_end
  end
  def self.short_days
    Day.all - long_days
  end

  def self.tear_down_set_up
    transaction do
      Week.destroy_all

      (19..36).each{|kw| raise('af') unless Week.create(number: kw) }

      Day.all.each do |day|
        day.shifts << Shift.new(shiftinfo_id:  1)
        day.shifts << Shift.new(shiftinfo_id: 12)
        day.shifts << Shift.new(shiftinfo_id:  6)

        day.shifts << Shift.new(shiftinfo_id: 32)
        day.shifts << Shift.new(shiftinfo_id: 33)
        day.shifts << Shift.new(shiftinfo_id: 35)

        case day.date.wday % 7
        when 1, 2, 3, 4, 5
          day.shifts << Shift.new(shiftinfo_id:  3)
          day.shifts << Shift.new(shiftinfo_id: 38)
        when 6, 0
          day.shifts << Shift.new(shiftinfo_id: 39)
          day.shifts << Shift.new(shiftinfo_id: 40)
          day.shifts << Shift.new(shiftinfo_id: 41)
        else
          raise 'nnooooooeeees'
        end
      end

      'Done.'
    end
  end

  private
  def self.people_by_saison_for_role( role_name, people )
    hash_by_saison(people){ |person, saison|
      person.has_role? role_name, saison
    }
  end
  def self.hash_by_saison collection  
    hash = Hash.new
    Saison.all.each{ |saison|
      hash[saison.name] = collection.select{ |elem| yield(elem, saison) }
    }
    return hash
  end
end
