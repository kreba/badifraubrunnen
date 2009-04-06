# Defines named roles for users that may be applied to
# objects in a polymorphic fashion. For example, you could create a role
# "moderator" for an instance of a model (i.e., an object), a model class,
# or without any specification at all.
class Role < ActiveRecord::Base
  has_and_belongs_to_many :people
  belongs_to :authorizable, :polymorphic => true

  def translate
    key = self.authorizable.nil? ? self.name : self.authorizable.name + self.name.capitalize
    I18n.translate "role.#{key}"
  end
end
