require 'minitest_helper'

describe 'Factories' do

  def self.is_saveable( name )
    it "creates a saveable #{name} stub" do
      record = FactoryGirl.build(name)
      record.valid?.must_equal true,
        "Record not valid: #{record.errors.messages.to_yaml}"
    end
  end

  is_saveable :person
  is_saveable :saison
  is_saveable :shiftinfo
  is_saveable :shift
  is_saveable :day
  is_saveable :week

end