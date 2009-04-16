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
    when "badi"
      "rgba( 38, 158, 0, 0.5)"
    when "kiosk"
      "rgba(255, 255, 0, 0.5)"
    end
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

  def self.shiftinfos_by_saison( shiftinfos = Shiftinfo.find(:all, :order => :begin, :include => :saison) )
    hash_by_saison(shiftinfos){ |shiftinfo, saison|
      shiftinfo.saison.eql? saison
    }
  end
  def self.staff_by_saison( people = Person.find(:all, :order => 'name') )
    people_by_saison_for_role('staff', people)
  end
  def self.admins_by_saison( people = Person.find(:all, :order => 'name') )
    people_by_saison_for_role('admin', people)
  end

  #How I populated the kiosk saison with shifts:
  #kiosk = Saison.find_by_name('kiosk')
  #y Shiftinfo.find_all_by_saison_id(kiosk)
  #[7,10].each{|n| Saison.long_days.each{|day| Shift.create!(:shiftinfo_id => n, :day_id => day.id); day.save!}}
  #[8,9].each{|n| Saison.short_days.each{|day| Shift.create!(:shiftinfo_id => n, :day_id => day.id); day.save!}}
  #Day.all.each{|day| day.create_status_image(kiosk)}
  def self.long_days
    high_saison = Day.all.select{ |day| (25..35).include?(day.week.number) }
    week_end    = Day.all.select{ |day| %w'Sat Sun'.include? day.date.strftime( '%a' ) }

    high_saison | week_end
  end
  def self.short_days
    Day.all - long_days
  end

  def self.badi
    find_by_name("badi")
  end
  def self.kiosk
    find_by_name("kiosk")
  end

  private
  def self.people_by_saison_for_role( role_name, people )
    hash_by_saison(people){ |person, saison|
      person.has_role? role_name, saison
    }
  end
  def self.hash_by_saison collection
    hash = Hash.new;
    Saison.all.each{ |saison|
      hash[saison.name] = collection.select{ |elem| yield(elem, saison) }
    }
    return hash
  end
end
