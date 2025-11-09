# frozen_string_literal: true

namespace :navigation_items do
  desc "Seed all navigation items from the seed file"
  task seed: :environment do
    puts "Seeding navigation items..."
    
    require Rails.root.join('lib', 'navigation_items_seeder')
    NavigationItemsSeeder.seed_navigation_items
  end
  
  desc "Reset all navigation items to default (WARNING: This will update all system items)"
  task reset: :environment do
    print "Are you sure you want to reset all navigation items? This will update all system items. (yes/no): "
    confirmation = STDIN.gets.chomp.downcase
    
    if confirmation == 'yes'
      require Rails.root.join('lib', 'navigation_items_seeder')
      NavigationItemsSeeder.seed_navigation_items
      puts "\n✓ Navigation items have been reset to defaults."
    else
      puts "Reset cancelled."
    end
  end
end
