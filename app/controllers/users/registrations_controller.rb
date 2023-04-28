# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  def after_update_path_for(resource)
    user_path(resource)
  end
end
