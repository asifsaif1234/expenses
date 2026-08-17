class Category < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :category_group, optional: true
  has_many :expenses, dependent: :restrict_with_error
  
  validates :name, presence: true, 
                   uniqueness: { scope: :user_id, 
                                message: "already exists for this user" }
  validates :icon, presence: true, length: { maximum: 10 }
  validates :color, presence: true, 
                    format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/, 
                             message: "must be a valid hex color (e.g., #FF0000)" }
  validates :description, length: { maximum: 500 }, allow_blank: true

  before_validation :set_defaults_for_system_category
  before_save :set_default_icon, if: -> { icon.blank? }
  
  scope :system, -> { where(user_id: nil) }
  scope :user_created, -> { where.not(user_id: nil) }
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :ordered, -> { order(:name) }
  scope :by_group, -> { includes(:category_group).order('category_groups.position', 'categories.name') }
  scope :recent, -> { order(created_at: :desc) }
  scope :system_or_user, ->(user) { 
    where("user_id = ? OR user_id IS NULL", user.id) 
  }
  scope :by_group_id, ->(group_id) { where(category_group_id: group_id) if group_id.present? }
  scope :by_user, ->(user) { where(user_id: user.id) }
  scope :search, ->(query) { 
    where("name LIKE ? OR description LIKE ?", "%#{query}%", "%#{query}%") if query.present?
  }
  
 def system_category?
    user_id.nil?
  end
  
  def user_category?
    user_id.present?
  end
  
  def display_name
    if system_category?
      "#{icon} #{name}"
    else
      "#{icon} #{name} (Custom)"
    end
  end

  def full_name
    "#{icon} #{name}"
  end
  
  def group_name
    category_group&.name || "Uncategorized"
  end
  
  def editable_by?(user)
    user_category? && user_id == user.id
  end
  
  def deletable_by?(user)
    user_category? && user_id == user.id && expenses.empty?
  end
  
  def total_expenses
    expenses.sum(:amount)
  end

  def expense_count
    expenses.count
  end
  
  def formatted_total
    "$#{'%.2f' % total_expenses}"
  end

  def self.all_for_user(user)
    system.active + user.categories.active
  end

  def self.grouped_by_group(user)
    includes(:category_group)
      .system_or_user(user)
      .active
      .ordered
      .by_group
      .group_by { |category| category.category_group }
  end
  
  def self.options_for_user(user)
    all_for_user(user).map { |c| [c.full_name, c.id] }
  end

  private
  
  def set_defaults_for_system_category
    if user_id.nil?
      self.is_system = true
    end
  end
  
  def set_default_icon
    self.icon = "📌"
  end
end
