begin
  require "bundler/inline"
rescue LoadError
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise
end

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "activerecord", "6.0.3.2"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.column :name, :string
  end

  create_table :posts do |t|
    t.references :user
    t.column :content, :string
    t.column :published, :boolean
  end
end

class User < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :user
end


class JoinTest < Minitest::Test
  def test_join
    alice = User.create!(name: 'Alice')
    bob = User.create!(name: 'Bob')
    alice.posts.create!(content: 'foo', published: true)
    alice.posts.create!(content: 'bar', published: true)
    alice.posts.create!(content: 'buz', published: false)
    bob.posts.create!(content: 'far', published: false)
    assert_equal [alice, alice], User.joins(:posts).where(posts: {published: true})
    assert_equal [alice, alice], User.left_joins(:posts).where(posts: {published: true})
    assert_equal [alice], User.includes(:posts).where(posts: {published: true})
    assert_equal [alice], User.eager_load(:posts).where(posts: {published: true})
  end
end
