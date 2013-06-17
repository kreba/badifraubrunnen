require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < ActiveRecord::TestCase

  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  test 'should_login_and_redirect' do
    post :create, login: 'quentin', password: 'test'
    assert session[:person_id]
    assert_response :redirect
  end

  test 'should_fail_login_and_not_redirect' do
    post :create, login: 'quentin', password: 'bad password'
    assert_nil session[:person_id]
    assert_response :success
  end

  test 'should_logout' do
    login_as :quentin
    get :destroy
    assert_nil session[:person_id]
    assert_response :redirect
  end

  test 'should_remember_me' do
    post :create, login: 'quentin', password: 'test', remember_me: "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  test 'should_not_remember_me' do
    post :create, login: 'quentin', password: 'test', remember_me: "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  test 'should_delete_token_on_logout' do
    login_as :quentin
    get :destroy
    assert_equal @response.cookies["auth_token"], []
  end

  test 'should_login_with_cookie' do
    people(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert @controller.send(:logged_in?)
  end

  test 'should_fail_expired_cookie_login' do
    people(:quentin).remember_me
    people(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:logged_in?)
  end

  test 'should_fail_cookie_login' do
    people(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(person)
      auth_token people(person).remember_token
    end
end
