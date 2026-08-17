# frozen_string_literal: true

class CategoryGroup < ApplicationRecord
  belongs_to :user, optional: true
  has_many :categories, dependent: :destroy

  validates :name, presence: true,
                   uniqueness: { scope: :user_id,
                                message: "already exists for this user" }
  validates :icon, presence: true, length: { maximum: 10 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # ============ Callbacks ============
  before_validation :set_defaults_for_system_group
  before_save :set_default_icon, if: -> { icon.blank? }
  before_create :set_position, unless: -> { position.present? }

  # ============ Scopes ============
  scope :system, -> { where(user_id: nil, is_system: true) }
  scope :user_created, -> { where.not(user_id: nil) }
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :ordered, -> { order(:position, :name) }
  scope :recent, -> { order(created_at: :desc) }
  scope :system_or_user, ->(user) {
    where("user_id = ? OR user_id IS NULL", user.id)
  }
  scope :by_user, ->(user) { where(user_id: user.id) }

  # ============ Instance Methods ============
  def system_group?
    user_id.nil?
  end

  def user_group?
    user_id.present?
  end

  def display_name
    if system_group?
      "#{icon} #{name}"
    else
      "#{icon} #{name} (Custom)"
    end
  end

  def full_name
    "#{icon} #{name}"
  end

  def active_categories_count
    categories.active.count
  end

  def total_expenses
    categories.joins(:expenses).sum("expenses.amount")
  end

  def editable_by?(user)
    user_group? && user_id == user.id
  end

  def deletable_by?(user)
    user_group? && user_id == user.id && categories.empty?
  end

  # ============ Class Methods ============
  def self.all_for_user(user)
    system.active + user.category_groups.active
  end

  def self.options_for_user(user)
    all_for_user(user).map { |g| [ g.full_name, g.id ] }
  end

  def self.seed_system_groups
    default_groups = [
      { name: "Daily", icon: "📅", position: 1 },
      { name: "Food & Drinks", icon: "🍕", position: 2 },
      { name: "Transportation", icon: "🚗", position: 3 },
      { name: "Shopping", icon: "🛍️", position: 4 },
      { name: "Bills & Utilities", icon: "📋", position: 5 },
      { name: "Entertainment", icon: "🎬", position: 6 },
      { name: "Health & Fitness", icon: "💪", position: 7 },
      { name: "Travel", icon: "✈️", position: 8 },
      { name: "Education", icon: "📚", position: 9 },
      { name: "Housing", icon: "🏠", position: 10 },
      { name: "Insurance", icon: "🛡️", position: 11 },
      { name: "Personal Care", icon: "💅", position: 12 },
      { name: "Pets", icon: "🐕", position: 13 },
      { name: "Gifts & Donations", icon: "🎁", position: 14 },
      { name: "Other", icon: "📌", position: 15 },
    ]

    default_groups.each do |group|
      find_or_create_by(name: group[:name], user_id: nil) do |g|
        g.icon = group[:icon]
        g.position = group[:position]
        g.is_system = true
        g.is_active = true
      end
    end
  end

  private

  def set_defaults_for_system_group
    if user_id.nil?
      self.is_system = true
    end
  end

  def set_default_icon
    self.icon = "📁"
  end

  def set_position
    self.position = (self.class.maximum(:position) || 0) + 1
  end
end
