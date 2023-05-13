# frozen_string_literal: true

require 'application_system_test_case'

class ReportsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    @report = reports(:report_of_alice)

    alice = users(:alice)
    login_as(alice, scope: :user)
  end

  test 'visiting the index' do
    visit reports_url
    assert_selector 'h1', text: '日報の一覧'
  end

  test 'should create report' do
    visit reports_url
    click_on '日報の新規作成'

    fill_in 'タイトル', with: 'テスト用の日報です'
    fill_in '内容', with: 'これはテストです。'
    click_on '登録する'

    assert_text '日報が作成されました。'
    click_on '日報の一覧に戻る'
    assert_selector 'h1', text: '日報の一覧'
  end

  test 'should update Report' do
    visit report_url(@report)
    click_on 'この日報を編集'

    fill_in 'タイトル', with: '更新しました'
    fill_in '内容', with: '無事に更新されました！'
    click_on '更新する'

    assert_text '日報が更新されました。'
    click_on '日報の一覧に戻る'
    assert_selector 'h1', text: '日報の一覧'
  end

  test 'should destroy Report' do
    visit report_url(@report)
    click_on 'この日報を削除'

    assert_text '日報が削除されました。'
  end
end
