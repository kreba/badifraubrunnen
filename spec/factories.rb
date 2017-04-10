FactoryGirl.define do |f|
  class << f
    def next_id( model_class )
      next_val model_class, :id, 1
    end

    def next_week_number
      next_val Week, :number, 18
    end

    def next_val( model_class, attribute, or_first )
      last_val = model_class.maximum(attribute)
      last_val ? last_val + 1 : or_first
    end
  end


  factory :person do
    transient do
      sequence(:id) { f.next_id(Person) }
    end

    login { "abcxy#{id}" }
    password '123456'
    password_confirmation { password }
    name  { "Nam Von Toess #{id}" }
    email { "mailmay#{id}@gmail.com" }
    phone '011 000 00 00'
  end

  factory :saison do
    transient do
      sequence(:id) { f.next_id(Saison) }
    end

    name { "Ressort_#{id}" }
    self.begin  Date.commercial( Date.today.year , 18 , 5 )
    self.end    Date.commercial( Date.today.year , 37 , 7 )

    factory :badi do
      name 'badi'
    end
    factory :kiosk do
      name 'kiosk'
    end
  end

  factory :shiftinfo do
    saison { Saison.badi || FactoryGirl.create(:badi) }
    description { "Morgen" }
    self.begin '09:30:00'
    self.end   '12:00:00'
  end

  factory :shift do
    shiftinfo
    day
  end

  factory :day do
    transient do
      wdaynum 1 # Monday
    end

    association :week, strategy: :build
    date { Date.commercial( Date.today.year , week.number , wdaynum ) }

    after :build do |day|
      # Only relevant in case the week was generated (and not passed in)
      # Discard the one day that was unnecessarily built and take its place
      day.week.days = day.week.days.map {|d| (d.date.eql? day.date) ? day : d }
    end
  end

  factory :week do
    sequence(:number) { f.next_week_number }

    after :build do |week|
      for wday in 1..7
        week.days << build(:day, week: week, wdaynum: wday)
      end
    end
  end

end
