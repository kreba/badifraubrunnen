require File.dirname(__FILE__) + '/../test_helper'

class ShiftsControllerTest < ActionController::TestCase
  
  test 'should_get_index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:shifts)
  end

  test 'should_get_new' do
    get :new
    assert_response :success
  end

  test 'should_create_shift' do
    assert_difference('Shift.count') do
      post :create, shift: { }
    end

    assert_redirected_to shift_path(assigns(:shift))
  end

  test 'should_show_shift' do
    get :show, id: shifts(:one).id
    assert_response :success
  end

  test 'should_get_edit' do
    get :edit, id: shifts(:one).id
    assert_response :success
  end

  test 'should_update_shift' do
    put :update, id: shifts(:one).id, shift: { }
    assert_redirected_to shift_path(assigns(:shift))
  end

  test 'should_destroy_shift' do
    assert_difference('Shift.count', -1) do
      delete :destroy, id: shifts(:one).id
    end

    assert_redirected_to shifts_path
  end
end
