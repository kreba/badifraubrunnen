require File.dirname(__FILE__) + '/../test_helper'

class ShiftinfosControllerTest < ActionController::TestCase
  
  test 'should_get_index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:shiftinfos)
  end

  test 'should_get_new' do
    get :new
    assert_response :success
  end

  test 'should_create_shiftinfo' do
    assert_difference('Shiftinfo.count') do
      post :create, shiftinfo: { }
    end

    assert_redirected_to shiftinfo_path(assigns(:shiftinfo))
  end

  test 'should_show_shiftinfo' do
    get :show, id: shiftinfos(:one).id
    assert_response :success
  end

  test 'should_get_edit' do
    get :edit, id: shiftinfos(:one).id
    assert_response :success
  end

  test 'should_update_shiftinfo' do
    put :update, id: shiftinfos(:one).id, shiftinfo: { }
    assert_redirected_to shiftinfo_path(assigns(:shiftinfo))
  end

  test 'should_destroy_shiftinfo' do
    assert_difference('Shiftinfo.count', -1) do
      delete :destroy, id: shiftinfos(:one).id
    end

    assert_redirected_to shiftinfos_path
  end
end
