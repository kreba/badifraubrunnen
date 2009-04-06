class Saison < ActiveRecord::Base
  # Authorization plugin
  acts_as_authorizable

  has_many :shiftinfos

  validates_presence_of :begin, :end, :name
  validates_uniqueness_of :name

  attr_accessible :begin, :end
  attr_readonly :name

  def self.shiftinfos_by_saison( collection = Shiftinfo.find(:all, :include => :saison) )
    hash_by_saison(collection){ |shiftinfo, saison|
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
