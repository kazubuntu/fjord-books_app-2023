# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @alice = users(:alice)
  end

  test 'name_or_email' do
    assert_equal 'alice@example.com', @alice.name_or_email

    @alice.name = 'alice'
    assert_equal 'alice', @alice.name_or_email
  end
end
