# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @report_of_alice = reports(:report_of_alice)
    @report_of_bob = reports(:report_of_bob)
  end

  test 'should be able to edit my report' do
    assert @report_of_alice.editable?(@alice)
  end

  test 'should be date' do
    assert_equal Date, @report_of_alice.created_on.class
  end

  test 'should save mentions' do
    new_report_of_alice = @alice.reports.build(
      title: 'I like this report',
      content: "http://localhost:3000/reports/#{@report_of_bob.id}"
    )
    new_report_of_alice.save!
    assert_equal [@report_of_bob], new_report_of_alice.mentioning_reports
  end

  test 'should update mentions' do
    @report_of_alice.update!(
      title: 'I like this report',
      content: "http://localhost:3000/reports/#{@report_of_bob.id}"
    )
    assert_equal [@report_of_bob], @report_of_alice.mentioning_reports
  end
end
