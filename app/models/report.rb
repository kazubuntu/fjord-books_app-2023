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

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  def save_with_mentions
    transaction do
      save!
      mentioned_ids = find_mentioned_ids(content)
      create_mentioning_reports(mentioned_ids)
    end
    true
  rescue ActiveRecord::RecordInvalid
    add_mention_errors unless @mention.errors.empty?
    false
  end

  def update_with_mentions(report_params)
    transaction do
      update!(report_params)
      old_mentioned_ids = mentioning_report_ids
      new_mentioned_ids = find_mentioned_ids(content)
      destroy_mentioning_reports(old_mentioned_ids - new_mentioned_ids)
      create_mentioning_reports(new_mentioned_ids - old_mentioned_ids)
    end
    true
  rescue ActiveRecord::RecordInvalid
    add_mention_errors unless @mention.errors.empty?
    false
  end

  private

  def find_mentioned_ids(content)
    content.scan(%r{http://localhost:3000/reports/(\d+)}).flatten.map(&:to_i).uniq
  end

  def create_mentioning_reports(mentioned_ids)
    mentioned_ids.each do |mentioned_id|
      @mention = active_relationships.build(mentioned_id:)
      @mention.save! unless mentioned_id == id
    end
  end

  def destroy_mentioning_reports(mentioned_ids)
    mentioned_ids.each do |mentioned_id|
      @mention = active_relationships.find_by(mentioned_id:)
      @mention.destroy!
    end
  end

  def add_mention_errors
    @mention.errors.full_messages.each { |error_message| errors.add(:base, error_message) }
  end
end
