# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable, :lockable, :timeoutable

  has_many :expenses, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :category_groups, dependent: :destroy

  validates :first_name, presence: true, if: -> { first_name.present? }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def total_expenses
    expenses.sum(:amount)
  end

  def monthly_expenses(year, month)
    expenses.where("EXTRACT(year FROM expense_date) = ? AND EXTRACT(month FROM expense_date) = ?", year, month)
  end

  def category_breakdown(year, month)
    expenses.joins(:category)
            .where("EXTRACT(year FROM expense_date) = ? AND EXTRACT(month FROM expense_date) = ?", year, month)
            .group("categories.id, categories.name, categories.color, categories.icon")
            .sum(:amount)
  end

  def group_breakdown(year, month)
    expenses.joins(category: :category_group)
            .where("EXTRACT(year FROM expense_date) = ? AND EXTRACT(month FROM expense_date) = ?", year, month)
            .group("category_groups.id, category_groups.name, category_groups.icon")
            .sum(:amount)
  end

  def available_categories
    Category.system_or_user(self).active.ordered
  end

  def available_groups
    CategoryGroup.system_or_user(self).active.ordered
  end

  def active_for_authentication?
    super && !is_locked? # Example: check if user is locked
  end

  def is_locked?
    false # Implement your own logic
  end
end
