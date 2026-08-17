class Expense < ApplicationRecord
  # ============ Associations ============
  belongs_to :category
  belongs_to :user

  # ============ Validations ============
  validates :amount, presence: true, 
                     numericality: { greater_than: 0, less_than: 1_000_000 }
  validates :expense_date, presence: true
  validates :description, length: { maximum: 500 }, allow_blank: true
  
  # Validate category belongs to user or is system
  validate :category_belongs_to_user_or_system

  # ============ Scopes ============
  scope :recent, -> { order(expense_date: :desc, created_at: :desc) }
  scope :for_today, -> { where(expense_date: Date.current) }
  scope :for_month, ->(date = Date.current) { 
    where(expense_date: date.beginning_of_month..date.end_of_month) 
  }
  scope :for_year, ->(year = Date.current.year) { 
    where(expense_date: Date.new(year, 1, 1)..Date.new(year, 12, 31)) 
  }
  scope :by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
  scope :by_date_range, ->(start_date, end_date) { 
    where(expense_date: start_date..end_date) if start_date.present? && end_date.present? 
  }
  scope :by_user, ->(user) { where(user_id: user.id) }
  scope :search, ->(query) { 
    where("description LIKE ?", "%#{query}%") if query.present?
  }
  
  # ============ Instance Methods ============
  def formatted_amount
    "$#{'%.2f' % amount}"
  end
  
  def short_description
    description.present? ? description.truncate(50) : "No description"
  end
  
  def category_name
    category&.name || "Unknown"
  end
  
  def category_icon
    category&.icon || "📌"
  end
  
  def group_name
    category&.category_group&.name || "Uncategorized"
  end
  
  private
  
  def category_belongs_to_user_or_system
    return if category.nil?
    unless category.user_id.nil? || category.user_id == user_id
      errors.add(:category, "must be a system category or your own category")
    end
  end
end
