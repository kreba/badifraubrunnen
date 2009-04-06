class AddTypeToSaison < ActiveRecord::Migration
  def self.up
    add_column :saisons, :name, :string
    add_column :shiftinfos, :saison_id, :integer

    saison = Saison.find(:first) || Saison.new(:begin => '2009-03-01', :end => '2009-09-30')
    saison.name = "badi"
    saison.save!
    for si in Shiftinfo.find(:all)
      si.saison = saison
      si.save!
    end
  end

  def self.down
    remove_column :saisons, :type
    remove_column :shifts,  :saison_id
  end
end
