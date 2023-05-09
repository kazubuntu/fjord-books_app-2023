# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :active_relationships, class_name: 'Relationship', foreign_key: :mentioning_id, inverse_of: 'mentioning', dependent: :destroy
  has_many :mentioning_reports, through: :active_relationships, source: :mentioned

  has_many :passive_relationships, class_name: 'Relationship', foreign_key: :mentioned_id, inverse_of: 'mentioned', dependent: :destroy
  has_many :mentioned_reports, through: :passive_relationships, source: :mentioning

  validates :title, presence: true
  validates :content, presence: true

  after_create :create_mentions
  after_update :update_mentions

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  def create_mentions
    mentioned_ids = find_mentioned_ids(content)
    create_mentioning_reports(mentioned_ids)
  end

  def update_mentions
    old_mentioned_ids = mentioning_report_ids
    new_mentioned_ids = find_mentioned_ids(content)
    destroy_mentioning_reports(old_mentioned_ids - new_mentioned_ids)
    create_mentioning_reports(new_mentioned_ids - old_mentioned_ids)
  end

  private

  def find_mentioned_ids(content)
    mentioned_ids = content.scan(%r{http://localhost:3000/reports/(\d+)}).flatten.map(&:to_i).uniq
    mentioned_ids & Report.ids
  end

  def create_mentioning_reports(mentioned_ids)
    mentioned_ids.each { |mentioned_id| active_relationships.create!(mentioned_id:) unless mentioned_id == id }
  end

  def destroy_mentioning_reports(mentioned_ids)
    mentioned_ids.each { |mentioned_id| active_relationships.find_by!(mentioned_id:).destroy! }
  end
end
