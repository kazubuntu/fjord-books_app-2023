# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @report_of_alice = reports(:report_of_alice)
    @report_of_bob = reports(:report_of_bob)
    @report_of_carol = reports(:report_of_carol)
    @report_of_dave = reports(:report_of_dave)
  end

  test 'editable?' do
    assert @report_of_alice.editable?(@alice)
    assert_not @report_of_alice.editable?(@bob)
  end

  test 'created_on' do
    assert_equal Date.current, @report_of_alice.created_on
  end

  test 'save_mentions' do # rubocop:disable Metrics/BlockLength
    # 他の日報のURLを含んで新規作成すると、その日報を言及する
    new_report_of_alice = @alice.reports.build(
      title: 'I like this report',
      content: "http://localhost:3000/reports/#{@report_of_bob.id}"
    )
    new_report_of_alice.save!
    assert_equal [@report_of_bob], new_report_of_alice.mentioning_reports

    # 複数の日報のURLを含んで新規作成すると、その日報を言及する
    new_report_of_alice = @alice.reports.build(
      title: 'I like this report',
      content: <<~TEXT
        http://localhost:3000/reports/#{@report_of_bob.id}が好き。
        http://localhost:3000/reports/#{@report_of_carol.id}も好き。
        http://localhost:3000/reports/#{@report_of_dave.id}が1番好き。
      TEXT
    )
    new_report_of_alice.save!
    assert_includes new_report_of_alice.mentioning_reports, @report_of_bob
    assert_includes new_report_of_alice.mentioning_reports, @report_of_carol
    assert_includes new_report_of_alice.mentioning_reports, @report_of_dave

    # 他の日報のURLを含まない場合は言及しない
    new_report_of_alice = @alice.reports.build(
      title: '今日は楽しかった',
      content: 'いい一日だった'
    )
    new_report_of_alice.save!
    assert_equal [], new_report_of_alice.mentioning_reports

    # 他の日報のURLを含んで更新すると、その日報を言及する
    @report_of_alice.update!(
      title: 'I like this report',
      content: "http://localhost:3000/reports/#{@report_of_bob.id}"
    )
    updated_report_of_alice = Report.find(@report_of_alice.id)
    assert_equal [@report_of_bob], updated_report_of_alice.mentioning_reports

    # 複数の日報のURLを含んで更新すると、その日報を言及する
    @report_of_alice.update!(
      title: 'I like this report',
      content: <<~TEXT
        http://localhost:3000/reports/#{@report_of_bob.id}が好き。
        http://localhost:3000/reports/#{@report_of_carol.id}も好き。
        http://localhost:3000/reports/#{@report_of_dave.id}が1番好き。
      TEXT
    )
    updated_report_of_alice = Report.find(@report_of_alice.id)
    assert_includes updated_report_of_alice.mentioning_reports, @report_of_bob
    assert_includes updated_report_of_alice.mentioning_reports, @report_of_carol
    assert_includes updated_report_of_alice.mentioning_reports, @report_of_dave

    # 自分の日報には言及しない
    @report_of_alice.update!(
      title: 'My report',
      content: "http://localhost:3000/reports/#{@report_of_alice.id}"
    )
    updated_report_of_alice = Report.find(@report_of_alice.id)
    assert_equal [], updated_report_of_alice.mentioning_reports

    # 他の日報のURLを含まない場合は言及しない
    @report_of_alice.update!(
      title: '今日は疲れた',
      content: '大変だった'
    )
    updated_report_of_alice = Report.find(@report_of_alice.id)
    assert_equal [], updated_report_of_alice.mentioning_reports
  end
end
