# Defines named roles for users that may be applied to
# objects in a polymorphic fashion. For example, you could create a role
# "moderator" for an instance of a model (i.e., an object), a model class,
# or without any specification at all.
class Role < ApplicationRecord
  has_and_belongs_to_many :people
  belongs_to :authorizable, polymorphic: true

  # A virtual attribute to work around a bug in the authorization gem
  # (authorization-1.0.12/lib/publishare/object_roles_table.rb:52)
  def users
    people
  end

  def translate
    key = self.authorizable.nil? ? self.name : self.authorizable.name + self.name.capitalize
    I18n.translate "role.#{key}"
  end

  # AutHack that enables us to temporarily contiue using the authorization gem
  def self.find_all_by_name(role_name)
    where(name: role_name)
  end
  def self.find_all_by_authorizable_type_and_name(type_name, role_name)
    where(authorizable_type: type_name, name: role_name)
  end
end
