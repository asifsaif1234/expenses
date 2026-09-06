# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
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
end
