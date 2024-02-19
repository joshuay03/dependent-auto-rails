# frozen_string_literal: true

require "test_helper"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new($stdout)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base
  has_many :comments, dependent: :auto
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class AssociationTest < Minitest::Test
  def test_dependent_auto
    post = Post.create!
    post.comments << Comment.create!
    post.comments << Comment.create!

    assert post.destroy
    assert_equal 0, Comment.count
  end
end
