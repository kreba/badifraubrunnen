require 'minitest_helper'

describe 'Integration' do

  describe 'Authentication' do
  
    it 'successfully logs in with valid credentials' do
      globi = FactoryGirl.create(:person)
      visit login_path
      fill_in t('person.attributes.login')    , with: globi.login
      fill_in t('person.attributes.password') , with: globi.password
      click_button t('sessions.login')
      page.find('#side').must_have_content globi.name
    end  
    it 'does not log in upon invalid credentials' do
      schnegge = FactoryGirl.create(:person)
      visit login_path
      fill_in t('person.attributes.login')    , with: schnegge.login
      fill_in t('person.attributes.password') , with: '_wrong_'
      click_button t('sessions.login')
      page.find('#side').wont_have_content schnegge.name
    end
  
    it 'logs in a valid user with the helper method' do skip
      login_as FactoryGirl.create(:person)
      visit help_path
      page.find('#side').must_have_content user.name
    end
    
  end

end