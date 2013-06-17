require File.dirname(__FILE__) + '/../test_helper'
require 'days_controller'

class DaysControllerTest < ActionController::TestCase
  
  test 'should_show_day' do
    login_as people(:quentin)
    get :show, id: days(:kw19_d1).id
    assert_response :success
  end

  test 'should_update_day' do
    put :update, id: days(:kw19_d1).id, day: { }
    assert_redirected_to day_path(assigns(:day))
  end

end
