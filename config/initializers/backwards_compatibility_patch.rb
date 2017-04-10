# Monkey patch for Rails backwards compatibility.
# The authentication gem's original method uses the old style finder method find(:first, :conditions => {...})

require 'publishare/object_roles_table'
module Authorization
  module ObjectRolesTable
    module InstanceMethods

      private

      def get_role( role_name, authorizable_obj )
        if authorizable_obj.is_a? Class
          Role.find_by name:              role_name,
                       authorizable_type: authorizable_obj.to_s,
                       authorizable_id:   nil
        elsif authorizable_obj
          Role.find_by name:              role_name,
                       authorizable_type: authorizable_obj.class.base_class.to_s,
                       authorizable_id:   authorizable_obj.id
        else
          Role.find_by name:              role_name,
                       authorizable_type: nil,
                       authorizable_id:   nil
        end
      end

    end
  end
end
