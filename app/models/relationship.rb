# frozen_string_literal: true

class Relationship < ApplicationRecord
  belongs_to :mentioning
  belongs_to :mentioned
end
