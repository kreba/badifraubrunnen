require 'digest/sha1'
class Person < ActiveRecord::Base
  before_save :encrypt_password
  #before_create :make_activation_code
  after_destroy :free_all_shifts

  has_many :shifts
  
  has_many :weeks  #als Wochenverantwortliche/r

  # Authorization plugin
  acts_as_authorized_user
  acts_as_authorizable
  # Encapsulating the account info gererated by restful_authentication would be a nice thing, but how to do it RESTful?
  # -> have a look at FormHelper#fields_for

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :name, :login, :phone
  validates_uniqueness_of   :name, :login, :case_sensitive => false
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_length_of       :name,     :within => 3..50
  validates_length_of       :login,    :within => 3..20
  validates_length_of       :email,    :maximum => 100
  validates_length_of       :address,  :maximum =>  50,                                      :allow_blank => true
  validates_length_of       :location, :maximum =>  30,                                      :allow_blank => true
  validates_format_of       :postal_code, :with => /\A([1-9][0-9]{3})\Z/,                    :allow_blank => true, :message => 'invalid_zip'.lc
  validates_format_of       :phone2, :with => /\A(0[1-9]{2} [0-9]{3} [0-9]{2} [0-9]{2})\Z/i, :allow_blank => true, :message => 'invalid_phone'.lc
  validates_format_of       :phone,  :with => /\A(0[1-9]{2} [0-9]{3} [0-9]{2} [0-9]{2})\Z/i,                       :message => 'invalid_phone'.lc
  validates_email_veracity_of :email, :message => 'invalid_email'.lc
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :name, :login, :phone, :phone2, :address, :postal_code, :location, 
                  :email, :preferences, :shifts, :password, :password_confirmation
                  #TODO: hide :shifts, :password and :password_confirmation ?

  def full_address_str
    str = ""
    str << address unless !address  # must append instead of a direct assignment in order to get a copy
    str << (str.empty? ? "" : ", ") + postal_code.to_s unless !postal_code 
    str << (str.empty? ? "" : " ") + location unless !location
    return str
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 1.hour
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
  private
    def free_all_shifts
      self.shifts.each {| shift | shift.forget_person! }
    end
end
  
