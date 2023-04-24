# frozen_string_literal: true

module ApplicationHelper
  def ja_pluralize(word)
    Rails.application.config.i18n.default_locale == :ja ? word : word.pluralize
  end
end
