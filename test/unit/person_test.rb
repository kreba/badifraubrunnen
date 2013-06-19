require 'test_helper'

class PersonTest < ActiveRecord::TestCase

  setup do
    @quentin = create_person
  end

  test 'should_create_person' do
    assert_difference 'Person.count' do
      person = create_person
      assert !person.new_record?, "#{person.errors.full_messages.to_sentence}"
    end
  end

  test 'should_require_login' do
    assert_no_difference 'Person.count' do
      u = build_and_validate_person(login: nil)
      assert u.errors[:login].any?
    end
  end

  test 'should_require_password' do
    assert_no_difference 'Person.count' do
      u = build_and_validate_person(password: nil)
      assert u.errors[:password].any?
    end
  end

  test 'should_require_password_confirmation' do
    assert_no_difference 'Person.count' do
      u = build_and_validate_person(password_confirmation: nil)
      assert u.errors[:password_confirmation].any?
    end
  end

  test 'should_require_email' do
    assert_no_difference 'Person.count' do
      u = build_and_validate_person(email: nil)
      assert u.errors[:email].any?
    end
  end

  test 'should_authenticate_person' do
    assert_equal @quentin, Person.authenticate(@quentin.login, @quentin.password)
  end

  test 'should_reset_password' do
    old_pw = @quentin.password
    new_pw = 'verysecurepassword'

    assert_equal @quentin, Person.authenticate(@quentin.login, old_pw)

    @quentin.update_attributes!(password: new_pw, password_confirmation: new_pw)

    assert_equal @quentin, Person.authenticate(@quentin.login, new_pw)
    assert_equal nil,     Person.authenticate(@quentin.login, old_pw)
  end

  test 'should_not_rehash_password_on_update' do
    old_login = @quentin.login
    new_login = 'newloginstring'

    assert_equal @quentin, Person.authenticate(old_login, @quentin.password)

    @quentin.update_attributes!(login: new_login)

    assert_equal @quentin, Person.authenticate(new_login, @quentin.password)
    assert_equal nil,     Person.authenticate(old_login, @quentin.password)
  end

  test 'should_set_remember_token' do
    @quentin.remember_me
    assert_not_nil @quentin.remember_token
    assert_not_nil @quentin.remember_token_expires_at
  end

  test 'should_unset_remember_token' do
    @quentin.remember_me
    assert_not_nil @quentin.remember_token
    @quentin.forget_me
    assert_nil @quentin.remember_token
  end

  test 'should_remember_me_for_one_week' do
    before = 1.week.from_now.utc
    @quentin.remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil @quentin.remember_token
    assert_not_nil @quentin.remember_token_expires_at
    assert @quentin.remember_token_expires_at.between?(before, after)
  end

  test 'should_remember_me_until_one_week' do
    time = 1.week.from_now.utc
    @quentin.remember_me_until time
    assert_not_nil @quentin.remember_token
    assert_not_nil @quentin.remember_token_expires_at
    assert_equal @quentin.remember_token_expires_at, time
  end

  test 'should_remember_me_default_two_weeks' do
    before = (Time.now + Person::REMEMBER_ME_TIME).utc
    @quentin.remember_me
    after = (Time.now + Person::REMEMBER_ME_TIME).utc
    assert_not_nil @quentin.remember_token
    assert_not_nil @quentin.remember_token_expires_at
    assert @quentin.remember_token_expires_at.utc.between?(before, after), 
      "Expected expiry to be bewteen #{before} and #{after}, but was #{@quentin.remember_token_expires_at.utc}"
  end

private
  
  def create_person options = {}
    FactoryGirl.create(:person, options)
  end
  
  def build_and_validate_person options = {}
    person = FactoryGirl.build(:person, options)
    person.valid?
    person
  end
  
end
