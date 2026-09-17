# config/initializers/pagy.rb
require "pagy"

Pagy.options[:items] = 20
Pagy.options[:overflow] = :last_page