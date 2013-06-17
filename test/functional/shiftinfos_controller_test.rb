require File.dirname(__FILE__) + '/../test_helper'

class ShiftinfosControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:shiftinfos)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_shiftinfo
    assert_difference('Shiftinfo.count') do
      post :create, shiftinfo: { }
    end

    assert_redirected_to shiftinfo_path(assigns(:shiftinfo))
  end

  def test_should_show_shiftinfo
    get :show, id: shiftinfos(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, id: shiftinfos(:one).id
    assert_response :success
  end

  def test_should_update_shiftinfo
    put :update, id: shiftinfos(:one).id, shiftinfo: { }
    assert_redirected_to shiftinfo_path(assigns(:shiftinfo))
  end

  def test_should_destroy_shiftinfo
    assert_difference('Shiftinfo.count', -1) do
      delete :destroy, id: shiftinfos(:one).id
    end

    assert_redirected_to shiftinfos_path
  end
end
