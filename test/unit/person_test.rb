require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < ActiveRecord::TestCase

  test 'should_create_person' do
    assert_difference 'Person.count' do
      person = create_person
      assert !person.new_record?, "#{person.errors.full_messages.to_sentence}"
    end
  end

  test 'should_require_login' do
    assert_no_difference 'Person.count' do
      u = create_person(login: nil)
      assert u.errors[:login].any?
    end
  end

  test 'should_require_password' do
    assert_no_difference 'Person.count' do
      u = create_person(password: nil)
      assert u.errors[:password].any?
    end
  end

  test 'should_require_password_confirmation' do
    assert_no_difference 'Person.count' do
      u = create_person(password_confirmation: nil)
      assert u.errors[:password_confirmation].any?
    end
  end

  test 'should_require_email' do
    assert_no_difference 'Person.count' do
      u = create_person(email: nil)
      assert u.errors[:email].any?
    end
  end

  test 'should_reset_password' do
    old_pw = people(:quentin).password
    people(:quentin).update_attributes!(password: 'new password', password_confirmation: 'new password')
    assert_equal people(:quentin), Person.authenticate('quentin', 'new password')
    assert_equal nil, Person.authenticate('quentin', old_pw)
  end

  test 'should_not_rehash_password' do
    assert_equal people(:quentin), Person.authenticate('quentin', 'test')

    people(:quentin).update_attributes!(login: 'quentin2')

    assert_equal nil,              Person.authenticate('quentin', 'test')
    assert_equal people(:quentin), Person.authenticate('quentin2', 'test')
  end

  test 'should_authenticate_person' do
    assert_equal people(:quentin), Person.authenticate('quentin', 'test')
  end

  test 'should_set_remember_token' do
    people(:quentin).remember_me
    assert_not_nil people(:quentin).remember_token
    assert_not_nil people(:quentin).remember_token_expires_at
  end

  test 'should_unset_remember_token' do
    people(:quentin).remember_me
    assert_not_nil people(:quentin).remember_token
    people(:quentin).forget_me
    assert_nil people(:quentin).remember_token
  end

  test 'should_remember_me_for_one_week' do
    before = 1.week.from_now.utc
    people(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil people(:quentin).remember_token
    assert_not_nil people(:quentin).remember_token_expires_at
    assert people(:quentin).remember_token_expires_at.between?(before, after)
  end

  test 'should_remember_me_until_one_week' do
    time = 1.week.from_now.utc
    people(:quentin).remember_me_until time
    assert_not_nil people(:quentin).remember_token
    assert_not_nil people(:quentin).remember_token_expires_at
    assert_equal people(:quentin).remember_token_expires_at, time
  end

  test 'should_remember_me_default_two_weeks' do
    before = (Time.now + Person::REMEMBER_ME_TIME).utc
    people(:quentin).remember_me
    after = (Time.now + Person::REMEMBER_ME_TIME).utc
    assert_not_nil people(:quentin).remember_token
    assert_not_nil people(:quentin).remember_token_expires_at
    assert people(:quentin).remember_token_expires_at.utc.between?(before, after), 
      "Expected expiry to be bewteen #{before} and #{after}, but was #{people(:quentin).remember_token_expires_at.utc}"
  end

protected
  def create_person(options = {})
    record = Person.new({ 
      name: 'hugo',
      login: 'quire', 
      email: 'quire@example.com', 
      password: 'quire', 
      password_confirmation: 'quire',
      phone: '031 111 11 11'
    }.merge(options))
    record.save!
    record
  end
end
