require File.dirname(__FILE__) + '/../test_helper'
require 'people_controller'

# Re-raise errors caught by the controller.
class PeopleController; def rescue_action(e) raise e end; end

class PeopleControllerTest < ActiveRecord::TestCase

  def setup
    @controller = PeopleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  test 'should_allow_signup' do
    assert_difference 'Person.count' do
      create_person
      assert_response :redirect
    end
  end

  test 'should_require_login_on_signup' do
    assert_no_difference 'Person.count' do
      create_person(login: nil)
      assert assigns(:person).errors[:login].any?
      assert_response :success
    end
  end

  test 'should_require_password_on_signup' do
    assert_no_difference 'Person.count' do
      create_person(password: nil)
      assert assigns(:person).errors[:password].any?
      assert_response :success
    end
  end

  test 'should_require_password_confirmation_on_signup' do
    assert_no_difference 'Person.count' do
      create_person(password_confirmation: nil)
      assert assigns(:person).errors[:password_confirmation].any?
      assert_response :success
    end
  end

  test 'should_require_email_on_signup' do
    assert_no_difference 'Person.count' do
      create_person(email: nil)
      assert assigns(:person).errors[:email].any?
      assert_response :success
    end
  end
  

  

  protected
    def create_person(options = {})
      post :create, person: { login: 'quire', email: 'quire@example.com',
        password: 'quire', password_confirmation: 'quire' }.merge(options)
    end
end
