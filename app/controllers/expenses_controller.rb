# frozen_string_literal: true

# app/controllers/expenses_controller.rb
class ExpensesController < ApplicationController
  include Pagy::Method

  before_action :authenticate_user!
  before_action :set_expense, only: %i[edit update destroy]
  before_action :set_categories, only: %i[new create edit update]

  ITEMS_PER_PAGE = 20

  def index
    prepare_index_data

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    @expense = Expense.new(expense_date: Time.zone.today)

    render partial: "expenses/modal_form",
           locals: {
             expense: @expense,
             categories: @categories,
           },
           layout: false
  end

  def create
    @expense = current_user.expenses.new(expense_params)

    if valid_category? && @expense.save
      handle_successful_create
    else
      handle_failed_mutation
    end
  end

  def edit
    render partial: "expenses/modal_form",
           locals: {
             expense: @expense,
             categories: @categories,
           },
           layout: false
  end

  def update
    if valid_category? && @expense.update(expense_params)
      handle_successful_update
    else
      handle_failed_mutation
    end
  end

  def destroy
    @expense.destroy!

    respond_to do |format|
      format.html do
        redirect_to expenses_path(month: selected_month_param),
                    notice: "Expense deleted successfully."
      end

      format.turbo_stream do
        prepare_index_data

        flash.now[:notice] = "Expense deleted successfully."

        render turbo_stream: [
          turbo_stream.replace(
            "expenses_dashboard",
            partial: "expenses/dashboard"
          ),
          turbo_stream.replace(
            "flash_messages",
            partial: "shared/flash"
          ),
        ]
      end
    end
  end

  def dashboard
    # ============ STATIC DEMO DATA ============
    # This data will be replaced with real data later

    # User info
    @user_name = current_user&.full_name || current_user&.email || "User"

    # Current month/year
    @current_month = Time.zone.today.strftime("%B %Y")
    @current_year = Time.zone.today.year

    # ============ STATS CARDS DATA ============
    @stats = {
      total_balance: { value: 12450.75, change: 8.5, label: "Total Balance" },
      monthly_income: { value: 4850.00, change: 12.3, label: "Monthly Income" },
      monthly_expenses: { value: 2147.80, change: -3.2, label: "Monthly Expenses" },
      savings_rate: { value: 55.7, change: 5.1, label: "Savings Rate" },
    }

    # ============ MONTHLY TREND (Last 12 months) ============
    @monthly_trend = [
      { month: "Aug 2025", income: 4200, expenses: 2400, savings: 1800 },
      { month: "Sep 2025", income: 4500, expenses: 2200, savings: 2300 },
      { month: "Oct 2025", income: 4300, expenses: 2600, savings: 1700 },
      { month: "Nov 2025", income: 4800, expenses: 2100, savings: 2700 },
      { month: "Dec 2025", income: 5100, expenses: 2800, savings: 2300 },
      { month: "Jan 2026", income: 4600, expenses: 1900, savings: 2700 },
      { month: "Feb 2026", income: 4900, expenses: 2300, savings: 2600 },
      { month: "Mar 2026", income: 4400, expenses: 2500, savings: 1900 },
      { month: "Apr 2026", income: 5200, expenses: 2000, savings: 3200 },
      { month: "May 2026", income: 4700, expenses: 2400, savings: 2300 },
      { month: "Jun 2026", income: 5000, expenses: 2100, savings: 2900 },
      { month: "Jul 2026", income: 4850, expenses: 2147.80, savings: 2702.20 },
    ]

    # ============ CATEGORY BREAKDOWN ============
    @category_breakdown = {
      "Groceries" => { amount: 450.00, color: "#3b82f6", icon: "🛒" },
      "Dining" => { amount: 320.00, color: "#8b5cf6", icon: "🍕" },
      "Transport" => { amount: 280.00, color: "#ec4899", icon: "🚗" },
      "Shopping" => { amount: 350.00, color: "#f59e0b", icon: "🛍️" },
      "Bills" => { amount: 420.00, color: "#10b981", icon: "📋" },
      "Entertainment" => { amount: 180.00, color: "#ef4444", icon: "🎬" },
      "Health" => { amount: 95.00, color: "#6366f1", icon: "🏥" },
      "Education" => { amount: 52.80, color: "#14b8a6", icon: "📚" },
    }

    @total_expenses = @category_breakdown.values.sum { |cat| cat[:amount] }

    # ============ BUDGET DATA ============
    @budget = {
      monthly_budget: 3500.00,
      actual_expenses: 2147.80,
      remaining: 1352.20,
      categories: [
        { name: "Groceries", budget: 500, actual: 450 },
        { name: "Dining", budget: 400, actual: 320 },
        { name: "Transport", budget: 300, actual: 280 },
        { name: "Shopping", budget: 400, actual: 350 },
        { name: "Bills", budget: 450, actual: 420 },
        { name: "Entertainment", budget: 250, actual: 180 },
        { name: "Health", budget: 150, actual: 95 },
        { name: "Education", budget: 100, actual: 52.80 },
      ],
    }

    # ============ RECENT TRANSACTIONS ============
    @recent_transactions = [
      {
        date: "2026-07-28",
        description: "Costco - Weekly Groceries",
        category: "Groceries",
        icon: "🛒",
        amount: -156.23,
        type: "expense",
      },
      {
        date: "2026-07-27",
        description: "Salary Deposit",
        category: "Income",
        icon: "💰",
        amount: 2450.00,
        type: "income",
      },
      {
        date: "2026-07-26",
        description: "Uber Ride to Airport",
        category: "Transport",
        icon: "🚗",
        amount: -45.50,
        type: "expense",
      },
      {
        date: "2026-07-25",
        description: "Netflix Subscription",
        category: "Entertainment",
        icon: "🎬",
        amount: -15.99,
        type: "expense",
      },
      {
        date: "2026-07-24",
        description: "The Olive Garden - Dinner",
        category: "Dining",
        icon: "🍕",
        amount: -78.40,
        type: "expense",
      },
      {
        date: "2026-07-23",
        description: "Amazon - Office Supplies",
        category: "Shopping",
        icon: "🛍️",
        amount: -124.80,
        type: "expense",
      },
      {
        date: "2026-07-22",
        description: "Electricity Bill",
        category: "Bills",
        icon: "📋",
        amount: -89.50,
        type: "expense",
      },
      {
        date: "2026-07-21",
        description: "Freelance Payment",
        category: "Income",
        icon: "💼",
        amount: 850.00,
        type: "income",
      },
      {
        date: "2026-07-20",
        description: "Gym Membership",
        category: "Health",
        icon: "🏥",
        amount: -35.00,
        type: "expense",
      },
      {
        date: "2026-07-19",
        description: "Online Course - React",
        category: "Education",
        icon: "📚",
        amount: -52.80,
        type: "expense",
      },
    ]

    # ============ DAILY SPENDING (Last 30 days) ============
    @daily_spending = (0..29).map do |i|
      date = Time.zone.today - i.days
      {
        date: date.strftime("%b %d"),
        amount: [ 12.50, 23.75, 8.20, 45.30, 15.60, 32.10, 18.90, 56.40, 9.80, 27.30 ].sample,
        day: date.strftime("%A"),
      }
    end.reverse

    # ============ UPCOMING BILLS ============
    @upcoming_bills = [
      { name: "Internet Bill", amount: 59.99, due_date: "2026-08-05", icon: "🌐" },
      { name: "Phone Bill", amount: 45.00, due_date: "2026-08-10", icon: "📱" },
      { name: "Rent", amount: 1200.00, due_date: "2026-08-01", icon: "🏠" },
    ]

    # ============ QUICK STATS ============
    @quick_stats = {
      total_transactions: 142,
      total_categories: 12,
      average_monthly: 1875.40,
      highest_spending: "Groceries",
    }
  end

  private

  # INDEX
  def prepare_index_data
    @selected_date = parse_month(params[:month])

    today = Time.zone.today

    @month_range =
      @selected_date.beginning_of_month..@selected_date.end_of_month

    @expenses_scope = current_user.expenses
                                  .where(expense_date: @month_range)

    @pagy, @expenses = pagy(
      :offset,
      @expenses_scope
        .includes(:category)
        .order(expense_date: :desc, created_at: :desc, id: :desc),
      items: ITEMS_PER_PAGE
    )

    build_month_stats(@expenses_scope)
    build_year_stats
    build_category_totals(@expenses_scope)

    @month_name = @selected_date.strftime("%B %Y")
    @prev_month = @selected_date.prev_month
    @next_month = @selected_date.next_month

    @is_current_month =
      @selected_date.year == today.year &&
      @selected_date.month == today.month

    @can_go_next = @selected_date < today.beginning_of_month

    @selected_month_param = @selected_date.strftime("%Y-%m")
  end

  # CREATE
  def handle_successful_create
    flash[:notice] = "Expense added successfully."

    respond_to do |format|
      format.html do
        redirect_to expenses_path(
          month: @expense.expense_date.strftime("%Y-%m")
        )
      end

      format.turbo_stream do
        # Navigate the dashboard to the month where the new
        # expense actually belongs.
        @selected_date = @expense.expense_date.to_date

        prepare_index_data

        render turbo_stream: [
          turbo_stream.replace(
            "expenses_dashboard",
            partial: "expenses/dashboard"
          ),
          turbo_stream.replace(
            "flash_messages",
            partial: "shared/flash"
          ),
          turbo_stream.update(
            "expense_modal",
            ""
          ),
        ]
      end
    end
  end

  # UPDATE
  def handle_successful_update
    flash[:notice] = "Expense updated successfully."

    respond_to do |format|
      format.html do
        redirect_to expenses_path(
          month: @expense.expense_date.strftime("%Y-%m")
        )
      end

      format.turbo_stream do
        prepare_index_data

        render turbo_stream: [
          turbo_stream.replace(
            "expenses_dashboard",
            partial: "expenses/dashboard"
          ),
          turbo_stream.replace(
            "flash_messages",
            partial: "shared/flash"
          ),
          turbo_stream.update(
            "expense_modal",
            ""
          ),
        ]
      end
    end
  end

  # FAILED CREATE / UPDATE
  def handle_failed_mutation
    respond_to do |format|
      format.html do
        render(
          action_name == "create" ? :new : :edit,
          status: :unprocessable_entity
        )
      end

      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "modal_content",
            partial: "expenses/modal_form",
            locals: {
              expense: @expense,
              categories: @categories,
            }
          ),
        ], status: :unprocessable_entity
      end
    end
  end

  # MONTH STATISTICS

  def build_month_stats(scope)
    @month_total = scope.sum(:amount).to_f
    @month_count = scope.count

    today = Time.zone.today

    days =
      if @selected_date.year == today.year &&
         @selected_date.month == today.month
        today.day
      else
        @selected_date.end_of_month.day
      end

    @avg_daily =
      if days.positive?
        (@month_total / days).round(2)
      else
        0
      end

    @avg_transaction =
      if @month_count.positive?
        (@month_total / @month_count).round(2)
      else
        0
      end
  end

  # YEAR STATISTICS

  def build_year_stats
    year_range =
      @selected_date.beginning_of_year..@selected_date.end_of_year

    year_scope =
      current_user.expenses.where(expense_date: year_range)

    @year_total = year_scope.sum(:amount).to_f
    @year_count = year_scope.count

    @year_month_count =
      year_scope
        .where.not(expense_date: nil)
        .distinct
        .count(
          Arel.sql(
            "EXTRACT(MONTH FROM expense_date)"
          )
        )

    @year_avg_monthly =
      if @year_month_count.positive?
        (@year_total / @year_month_count).round(2)
      else
        0
      end

    @selected_year = @selected_date.year
  end

  # CATEGORY TOTALS
  def build_category_totals(scope)
    @category_totals =
      scope
        .joins(:category)
        .group(
          "categories.id",
          "categories.name",
          "categories.icon",
          "categories.color"
        )
        .sum(:amount)
        .map do |(id, name, icon, color), amount|
          [
            name,
            {
              id: id,
              amount: amount.to_f,
              icon: icon,
              color: color,
            },
          ]
        end
        .sort_by { |_name, data| -data[:amount] }
        .to_h
  end

  def valid_category?
    category_id = expense_params[:category_id]

    return true if category_id.blank?

    category =
      current_user
        .available_categories
        .find_by(id: category_id)

    return true if category.present?

    @expense.errors.add(
      :category_id,
      "is not valid"
    )

    false
  end

  def set_expense
    @expense =
      current_user.expenses.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to(
      expenses_path(month: selected_month_param),
      alert: "Expense not found."
    )
  end

  def set_categories
    @categories = current_user.available_categories
  end

  def expense_params
    params.require(:expense).permit(
      :amount,
      :expense_date,
      :description,
      :category_id
    )
  end

  # MONTH PARSING
  def parse_month(value)
    return Date.current.beginning_of_month if value.blank?

    Date.strptime(value.to_s, "%Y-%m").beginning_of_month
  rescue ArgumentError, TypeError
    Date.current.beginning_of_month
  end

  def selected_month_param
    parse_month(params[:month]).strftime("%Y-%m")
  end
end
