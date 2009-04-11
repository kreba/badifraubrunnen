class Saison < ActiveRecord::Base
  # Authorization plugin
  acts_as_authorizable

  has_many :shiftinfos

  validates_presence_of :begin, :end, :name
  validates_uniqueness_of :name

  attr_accessible :begin, :end
  attr_readonly :name

  def color
    case name
    when "badi"
      "rgba( 38, 162, 0, 0.6)"
    when "kiosk"
      "rgba(255, 255, 0, 0.6)"
    end
  end

  def daytime_limits
    times = self.shiftinfos
    min = times.min_by(&:begin).begin.seconds_since_midnight
    max = times.max_by(&:end).end.seconds_since_midnight
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
