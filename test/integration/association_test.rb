# frozen_string_literal: true

require "test_helper"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new($stdout)

ActiveRecord::Schema.define do
  create_table :posts, force: true

  create_table :comments, force: true do |t|
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base
  has_one :special_comment, class_name: "Comment", dependent: :auto
  has_many :comments, dependent: :auto
end

class PostWithCallbacks < Post
  attr_reader :callback_run_count

  has_one :special_comment, class_name: "Comment", foreign_key: :post_id, dependent: :auto
  has_many :comments, foreign_key: :post_id, dependent: :auto

  before_destroy :increment_callback_run_count

  private def increment_callback_run_count
    @callback_run_count = (@callback_run_count || 0) + 1
  end
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class AssociationTest < Minitest::Test
  class SingularAssociationTest < AssociationTest
    def test_dependent_auto
      post = Post.create!(special_comment: Comment.create!)

      assert_nothing_raised { post.destroy! }
      assert_equal 0, Comment.count
    end

    def test_dependent_auto_without_callbacks
      association = Post.reflect_on_association(:special_comment)
      assert_equal :delete, association.options[:dependent]

      post = Post.create!(special_comment: Comment.create!)

      assert post.destroy
      assert_equal 0, Comment.count
    end

    def test_dependent_auto_with_callbacks
      association = PostWithCallbacks.reflect_on_association(:special_comment)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithCallbacks.create!(special_comment: Comment.create!)

      assert post.destroy
      assert_equal 0, Comment.count
      assert_equal 1, post.callback_run_count
    end
  end

  class CollectionAssociationTest < AssociationTest
    def test_dependent_auto
      post = Post.create!
      post.comments << Comment.create!
      post.comments << Comment.create!

      assert_nothing_raised { post.destroy! }
      assert_equal 0, Comment.count
    end

    def test_dependent_auto_without_callbacks
      association = Post.reflect_on_association(:comments)
      assert_equal :delete_all, association.options[:dependent]

      post = Post.create!
      post.comments << Comment.create!
      post.comments << Comment.create!

      assert post.destroy
      assert_equal 0, Comment.count
    end

    def test_dependent_auto_with_callbacks
      association = PostWithCallbacks.reflect_on_association(:comments)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithCallbacks.create!
      post.comments << Comment.create!
      post.comments << Comment.create!

      assert post.destroy
      assert_equal 0, Comment.count
      assert_equal 1, post.callback_run_count
    end
  end
end
