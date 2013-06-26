Feature: Hello World
  In order to check out Cucumber
  As a testing n00b
  I want to verify that authentication in my app works as expected
  
  Scenario: Log in user with valid credentials
    Given an ordinary user exists
    When that user logs in using his password
    Then authentication should be successful

  Scenario: Log in user with invalid credentials
    Given an ordinary user exists
    When that user logs in using a wrong password
    Then authentication should fail

