# frozen_string_literal: true

require 'application_system_test_case'

class ReportsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    alice = users(:alice)
    login_as(alice, scope: :user)
  end

  test 'flow of report from login to destroying' do
    visit root_url

    # 日報の一覧ページへ移動
    click_on '日報'
    assert_selector 'h1', text: '日報の一覧'

    # 日報を作成する
    click_on '日報の新規作成'
    assert_selector 'h1', text: '日報の新規作成'

    fill_in 'タイトル', with: 'テスト用の日報です'
    fill_in '内容', with: 'これはテストです。'
    click_on '登録する'
    assert_text '日報が作成されました。'

    click_on '日報の一覧に戻る'
    assert_selector 'h1', text: '日報の一覧'

    # 日報を更新する
    click_on 'この日報を表示', match: :first
    assert_selector 'h1', text: '日報の詳細'

    click_on 'この日報を編集'
    assert_selector 'h1', text: '日報の編集'

    fill_in 'タイトル', with: '更新しました'
    fill_in '内容', with: '無事に更新されました！'
    click_on '更新する'
    assert_text '日報が更新されました。'

    click_on '日報の一覧に戻る'
    assert_selector 'h1', text: '日報の一覧'

    # 日報を削除する
    click_on 'この日報を表示', match: :first
    assert_selector 'h1', text: '日報の詳細'

    click_on 'この日報を削除'
    assert_text '日報が削除されました。'
  end
end
