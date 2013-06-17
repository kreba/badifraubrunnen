require File.dirname(__FILE__) + '/../test_helper'

class WeeksControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:weeks)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_week
    assert_difference('Week.count') do
      post :create, week: { }
    end

    assert_redirected_to week_path(assigns(:week))
  end

  def test_should_show_week
    get :show, id: weeks(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, id: weeks(:one).id
    assert_response :success
  end

  def test_should_update_week
    put :update, id: weeks(:one).id, week: { }
    assert_redirected_to week_path(assigns(:week))
  end

  def test_should_destroy_week
    assert_difference('Week.count', -1) do
      delete :destroy, id: weeks(:one).id
    end

    assert_redirected_to weeks_path
  end
end
