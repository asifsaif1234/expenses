# frozen_string_literal: true

puts "🌱 Starting seed..."

# ============ Clear existing data ============
puts "🧹 Clearing existing data..."
Category.destroy_all
CategoryGroup.destroy_all
Expense.destroy_all

# ============ Create Admin/Demo User with Devise ============
puts "👤 Creating demo user..."
demo_user = User.find_or_create_by(email: "demo@example.com") do |user|
  user.first_name = "Asif"
  user.last_name = "Saif"
  user.password = "password"
  user.password_confirmation = "password"
  user.confirmed_at = Time.current # Skip email confirmation
end

# Create additional test user
test_user = User.find_or_create_by(email: "test@example.com") do |user|
  user.first_name = "Oznil"
  user.last_name = "Miraan"
  user.password = "password"
  user.password_confirmation = "password"
  user.confirmed_at = Time.current
end

puts "✅ Users created:"
puts "  - #{demo_user.email} (password: password)"
puts "  - #{test_user.email} (password: password)"

# ============ Seed System Groups ============
puts "🌱 Seeding system groups..."
CategoryGroup.seed_system_groups

# ============ Seed System Categories ============
puts "🌱 Seeding system categories..."
system_categories = [
  # Daily
  { name: "Coffee", icon: "☕", color: "#8B4513", group: "Daily" },
  { name: "Snacks", icon: "🍿", color: "#FF6B35", group: "Daily" },
  { name: "Lunch", icon: "🥪", color: "#28A745", group: "Daily" },
  { name: "Dinner", icon: "🍽️", color: "#DC3545", group: "Daily" },
  
  # Food & Drinks
  { name: "Groceries", icon: "🛒", color: "#28A745", group: "Food & Drinks" },
  { name: "Restaurants", icon: "🍔", color: "#FD7E14", group: "Food & Drinks" },
  { name: "Takeaway", icon: "📦", color: "#6F42C1", group: "Food & Drinks" },
  
  # Transportation
  { name: "Fuel", icon: "⛽", color: "#007BFF", group: "Transportation" },
  { name: "Public Transport", icon: "🚌", color: "#17A2B8", group: "Transportation" },
  { name: "Taxi", icon: "🚕", color: "#FFC107", group: "Transportation" },
  { name: "Parking", icon: "🅿️", color: "#6C757D", group: "Transportation" },
  
  # Shopping
  { name: "Clothing", icon: "👕", color: "#E83E8C", group: "Shopping" },
  { name: "Electronics", icon: "📱", color: "#20C997", group: "Shopping" },
  { name: "Home Goods", icon: "🏪", color: "#DC3545", group: "Shopping" },
  
  # Bills & Utilities
  { name: "Electricity", icon: "💡", color: "#FFC107", group: "Bills & Utilities" },
  { name: "Water", icon: "💧", color: "#17A2B8", group: "Bills & Utilities" },
  { name: "Internet", icon: "🌐", color: "#007BFF", group: "Bills & Utilities" },
  { name: "Phone", icon: "📞", color: "#6F42C1", group: "Bills & Utilities" },
  
  # Entertainment
  { name: "Movies", icon: "🎬", color: "#DC3545", group: "Entertainment" },
  { name: "Games", icon: "🎮", color: "#28A745", group: "Entertainment" },
  { name: "Music", icon: "🎵", color: "#FD7E14", group: "Entertainment" },
  
  # Health & Fitness
  { name: "Gym", icon: "💪", color: "#28A745", group: "Health & Fitness" },
  { name: "Medicine", icon: "💊", color: "#DC3545", group: "Health & Fitness" },
  { name: "Doctor", icon: "🏥", color: "#007BFF", group: "Health & Fitness" },
  
  # Travel
  { name: "Hotels", icon: "🏨", color: "#FD7E14", group: "Travel" },
  { name: "Flights", icon: "✈️", color: "#007BFF", group: "Travel" },
  
  # Education
  { name: "Books", icon: "📚", color: "#28A745", group: "Education" },
  { name: "Courses", icon: "🎓", color: "#6F42C1", group: "Education" },
  
  # Housing
  { name: "Rent", icon: "🏠", color: "#DC3545", group: "Housing" },
  { name: "Maintenance", icon: "🔧", color: "#FD7E14", group: "Housing" },
  
  # Insurance
  { name: "Health Insurance", icon: "🛡️", color: "#28A745", group: "Insurance" },
  { name: "Car Insurance", icon: "🚗", color: "#007BFF", group: "Insurance" },
  
  # Personal Care
  { name: "Haircut", icon: "💇", color: "#E83E8C", group: "Personal Care" },
  { name: "Skincare", icon: "🧴", color: "#20C997", group: "Personal Care" },
  
  # Pets
  { name: "Pet Food", icon: "🐕", color: "#FD7E14", group: "Pets" },
  { name: "Veterinarian", icon: "🏥", color: "#DC3545", group: "Pets" },
  
  # Gifts
  { name: "Gifts", icon: "🎁", color: "#6F42C1", group: "Gifts & Donations" },
  { name: "Donations", icon: "🤝", color: "#28A745", group: "Gifts & Donations" },
  
  # Other
  { name: "Miscellaneous", icon: "📌", color: "#6C757D", group: "Other" }
]

system_categories.each do |cat|
  group = CategoryGroup.find_by(name: cat[:group], user_id: nil)
  Category.find_or_create_by(name: cat[:name], user_id: nil) do |c|
    c.icon = cat[:icon]
    c.color = cat[:color]
    c.category_group = group
    c.is_system = true
    c.is_active = true
    c.description = "System category"
  end
end

# ============ Create Custom Groups for Demo User ============
puts "🌱 Creating custom groups for demo user..."
custom_groups = [
  { name: "Freelance", icon: "💻" },
  { name: "Family", icon: "👨‍👩‍👧‍👦" },
  { name: "Side Projects", icon: "🚀" }
]

custom_groups.each do |group|
  CategoryGroup.find_or_create_by(name: group[:name], user_id: demo_user.id) do |g|
    g.icon = group[:icon]
    g.is_system = false
    g.is_active = true
  end
end

# ============ Create Custom Categories for Demo User ============
puts "🌱 Creating custom categories for demo user..."
custom_categories = [
  { name: "Freelance Tools", icon: "🛠️", color: "#FF6B35", group: "Freelance" },
  { name: "Client Meetings", icon: "🤝", color: "#007BFF", group: "Freelance" },
  { name: "Family Outings", icon: "👪", color: "#28A745", group: "Family" },
  { name: "Kids", icon: "👶", color: "#E83E8C", group: "Family" },
  { name: "Gadgets", icon: "📱", color: "#6F42C1", group: "Side Projects" }
]

custom_categories.each do |cat|
  group = CategoryGroup.find_by(name: cat[:group], user_id: demo_user.id)
  Category.find_or_create_by(name: cat[:name], user_id: demo_user.id) do |c|
    c.icon = cat[:icon]
    c.color = cat[:color]
    c.category_group = group
    c.is_system = false
    c.is_active = true
    c.description = "Custom category"
  end
end

# ============ Create Sample Expenses ============
puts "🌱 Creating sample expenses..."
available_categories = Category.system_or_user(demo_user).active

30.times do |i|
  Expense.create!(
    amount: rand(5.0..200.0).round(2),
    expense_date: Date.today - rand(0..90).days,
    description: [
      "Weekly groceries", 
      "Coffee break", 
      "Lunch meeting", 
      "Office supplies",
      "Dinner out", 
      "Gasoline", 
      "Movie night",
      "Gym session", 
      "Pet food", 
      "Shopping",
      "Internet bill",
      "Phone bill",
      "Electricity bill",
      "Car maintenance",
      "Doctor visit",
      "Books purchase",
      "Restaurant dinner",
      "Public transport",
      "Gift for friend",
      "Online subscription"
    ].sample,
    category: available_categories.sample,
    user: demo_user
  )
end

# ============ Create Expenses for Test User ============
puts "🌱 Creating sample expenses for test user..."
available_categories_test = Category.system_or_user(test_user).active

10.times do |i|
  Expense.create!(
    amount: rand(10.0..150.0).round(2),
    expense_date: Date.today - rand(0..30).days,
    description: [
      "Test grocery", 
      "Test lunch", 
      "Test shopping"
    ].sample,
    category: available_categories_test.sample,
    user: test_user
  )
end

# ============ Print Summary ============
puts "\n✅ Seed completed successfully!"
puts "=" * 50
puts "📊 Statistics:"
puts "  👤 Users:"
puts "    - Demo User: #{demo_user.email} (password: password)"
puts "    - Test User: #{test_user.email} (password: password)"
puts "  📁 System Groups: #{CategoryGroup.system.count}"
puts "  📁 User Groups: #{CategoryGroup.user_created.count}"
puts "  🏷️ System Categories: #{Category.system.count}"
puts "  🏷️ User Categories: #{Category.user_created.count}"
puts "  💰 Expenses: #{Expense.count}"
puts "=" * 50
puts "\n🚀 Application is ready!"
puts "🔑 Login with: demo@example.com / password"