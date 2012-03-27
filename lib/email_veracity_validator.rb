# As explained on http://railscasts.com/episodes/211-validations-in-rails-3
# (Ryan refers to http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)

class EmailVeracityValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    address = EmailVeracity::Address.new(value)
    unless address.valid?
      error_key = [*address.errors].first # This is either :malformed or the appropriate domain error.
      message = I18n.translate("person.invalid_email.#{error_key}")
      object.errors.add(attribute, message)
    end
  end
end
