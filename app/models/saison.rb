class Saison < ApplicationRecord
  # Authorization plugin
  acts_as_authorizable; include AutHack

  has_many :shiftinfos

  validates_presence_of :begin, :end, :name
  validates_uniqueness_of :name

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
    @@badi ||= find_by name: 'badi'
  end
  def self.kiosk
    @@kiosk ||= find_by name: 'kiosk'
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
  def self.staff_by_saison( people = Person.all.order(:name) )
    people_by_saison_for_role('staff', people)
  end
  def self.admins_by_saison( people = Person.all.order(:name) )
    people_by_saison_for_role('admin', people)
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
