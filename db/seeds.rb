# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create!(name: "Bob Law", email: "bob.law@example.com").tap do |user|
  user.blogs.create!(title: "Law Blog").tap do |blog|
    (1..10).each do |n|
      blog.posts.create! title: "The #{n.ordinalize} Post", user: user
    end
  end
end