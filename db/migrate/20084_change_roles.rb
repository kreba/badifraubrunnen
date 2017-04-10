class ChangeRoles < ActiveRecord::Migration
  @ressorts = ['badi', 'kiosk']

  def self.up
    for ressort in @ressorts
      (Person.all.select {|p| p.is_admin? and p.has_role? ressort+'Staff' }).each { |admin|
        admin.is_no_admin
        admin.has_role ressort+'Admin'
        # Keep the ...Staff role if set!
      }
    end

    # Clean up unused roles that were not destroyed due to a bug in previous releases
    Role.all.each{|r| r.destroy if r.people.none?}
  end

  def self.down
    for ressort in @ressorts
      (Person.all.select {|p| p.has_role? ressort+'Admin' }).each { |admin|
        admin.has_no_role ressort+'Admin'
        admin.has_role ressort+'Staff'
        admin.is_admin
      }
    end
  end
end
