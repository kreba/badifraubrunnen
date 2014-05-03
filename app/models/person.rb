require 'digest/sha1'
class Person < ActiveRecord::Base
  REMEMBER_ME_TIME = 1.hour
  
  # Authorization plugin
  acts_as_authorized_user
  acts_as_authorizable

  has_many :shifts
  has_many :weeks  #als Wochenverantwortliche/r

  before_save :encrypt_password
  after_destroy :free_all_shifts

  validates_uniqueness_of   :name, :login, case_sensitive: false
  validates_presence_of     :name, :login, :phone
  validates_presence_of     :password,                if: :password_required?
  validates_presence_of     :password_confirmation,   if: :password_required?
  validates_confirmation_of :password,                if: :password_required?
  validates_length_of       :password, within: 4..40, if: :password_required?
  validates_length_of       :name,     within: 3..50
  validates_length_of       :login,    within: 3..20
  validates_length_of       :email,    maximum: 100,                                      allow_blank: true
  validates_length_of       :address,  maximum:  50,                                      allow_blank: true
  validates_length_of       :location, maximum:  30,                                      allow_blank: true
  validates_format_of       :postal_code, with: /\A([1-9][0-9]{3})\Z/,                    allow_blank: true, message: I18n.translate('person.invalid_zip')
  validates_format_of       :phone,  with: /\A(0[1-9]{2} [0-9]{3} [0-9]{2} [0-9]{2})\Z/i, allow_blank: true, message: I18n.translate('person.invalid_phone')
  validates_format_of       :phone2, with: /\A(0[1-9]{2} [0-9]{3} [0-9]{2} [0-9]{2})\Z/i, allow_blank: true, message: I18n.translate('person.invalid_phone')

  # Uses Carsten Nielsen's email_veracity gem (see lib/EmailVeracityValidator.rb)
  validates :email, email_veracity: true
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  # Prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :name, :login, :phone, :phone2, :address, :postal_code, :location, 
                  :email, :preferences, :password, :password_confirmation, :brevet
  # :shifts is protected because it is not on this list.

  def full_address_str( options = {} )
    options.reverse_merge! delimiter: ', '
    str = ''
    str << address unless !address  # must append instead of a direct assignment in order to get a copy
    str << (str.empty? ? '' : options[:delimiter]) + postal_code.to_s if postal_code
    str << (str.empty? ? '' : ' ') + location if location
    return str.html_safe
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
    #(RAILS_ENV == 'production')^(name =~ /test\d/) and
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for REMEMBER_ME_TIME
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(validate: false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(validate: false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def administrates? person
    self.is_admin?
  end

  def roles_str
    self.roles.collect{ |role| role.translate }.to_sentence
  end
  def roles_key_for_cache
    keys = Array.new
    Saison.all.each{ |saison|
      keys << saison.name.first.upcase   if self.is_admin_for?( saison )
      keys << saison.name.first.downcase if self.is_staff_for?( saison )
    }
    keys << 'w' if self.is_webmaster?
    keys.sort.join
  end

  def my_saisons
    self.roles.all(include: :authorizable).collect(&:authorizable).flatten.uniq.compact.sort_by(&:name)
  end
  def all_saisons_but_mine_first
    my_saisons | Saison.all(order: :name)
  end
  def unrelated_saisons
    Saison.all(order: :name) - my_saisons
  end
  def admin_saisons
    is_admin_for_what.sort_by(&:name)
  end
  def non_admin_saisons
    (is_staff_for_what - is_admin_for_what) | unrelated_saisons
  end

  def self.find_by_role role_name
    roles = Role.find_all_by_name(role_name, include: :people)
    roles.collect{ |role| role.people }.flatten.uniq.sort_by(&:name)
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
  
