require File.dirname(__FILE__) + '/../test_helper'

class WeeksControllerTest < ActionController::TestCase

  test 'should_get_index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:weeks)
  end

  test 'should_get_new' do
    get :new
    assert_response :success
  end

  test 'should_create_week' do
    assert_difference('Week.count') do
      post :create, week: { }
    end

    assert_redirected_to week_path(assigns(:week))
  end

  test 'should_show_week' do
    get :show, id: weeks(:kw19).id
    assert_response :success
  end

  test 'should_get_edit' do
    get :edit, id: weeks(:kw19).id
    assert_response :success
  end

  test 'should_update_week' do
    put :update, id: weeks(:kw19).id, week: { }
    assert_redirected_to week_path(assigns(:week))
  end

  test 'should_destroy_week' do
    assert_difference('Week.count', -1) do
      delete :destroy, id: weeks(:kw19).id
    end

    assert_redirected_to weeks_path
  end
end
