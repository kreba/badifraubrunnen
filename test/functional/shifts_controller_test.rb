require File.dirname(__FILE__) + '/../test_helper'

class ShiftsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:shifts)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_shift
    assert_difference('Shift.count') do
      post :create, :shift => { }
    end

    assert_redirected_to shift_path(assigns(:shift))
  end

  def test_should_show_shift
    get :show, :id => shifts(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => shifts(:one).id
    assert_response :success
  end

  def test_should_update_shift
    put :update, :id => shifts(:one).id, :shift => { }
    assert_redirected_to shift_path(assigns(:shift))
  end

  def test_should_destroy_shift
    assert_difference('Shift.count', -1) do
      delete :destroy, :id => shifts(:one).id
    end

    assert_redirected_to shifts_path
  end
end
