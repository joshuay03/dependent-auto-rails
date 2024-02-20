# frozen_string_literal: true

# ---------- Start ActiveRecord Setup ----------

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
  has_one :comment, dependent: :auto
  has_many :comments, dependent: :auto
end

class PostWithDependentCallbacks < ActiveRecord::Base
  self.table_name = "posts"

  has_one :comment_with_callbacks, foreign_key: :post_id, dependent: :auto
  has_many :comments_with_callbacks, class_name: :CommentWithCallbacks, foreign_key: :post_id, dependent: :auto
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class CommentWithCallbacks < Comment
  self.table_name = "comments"

  class_attribute :callback_run_count

  belongs_to :post

  before_destroy :increment_callback_run_count

  private def increment_callback_run_count
    self.class.callback_run_count ||= 0
    self.class.callback_run_count += 1
  end
end

# ---------- End ActiveRecord Setup ----------

class AssociationIntegrationTest < Minitest::Test
  def setup
    Post.delete_all
    Comment.delete_all
    CommentWithCallbacks.callback_run_count = nil
  end

  class SingularAssociationIntegrationTest < AssociationIntegrationTest
    def test_dependent_auto
      post = Post.create!(comment: Comment.create!)

      assert_nothing_raised { post.destroy! }
      assert_equal 0, Comment.count
    end

    def test_dependent_auto_without_callbacks
      association = Post.reflect_on_association(:comment)
      assert_equal :delete, association.options[:dependent]

      post = Post.create!(comment: Comment.create!)

      assert post.destroy
      assert_equal 0, Comment.count
    end

    def test_dependent_auto_with_callbacks
      association = PostWithDependentCallbacks.reflect_on_association(:comment_with_callbacks)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithDependentCallbacks.create!(comment_with_callbacks: CommentWithCallbacks.create!)

      assert post.destroy
      assert_equal 0, CommentWithCallbacks.count
      assert_equal 1, CommentWithCallbacks.callback_run_count
    end
  end

  class CollectionAssociationIntegrationTest < AssociationIntegrationTest
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
      association = PostWithDependentCallbacks.reflect_on_association(:comments_with_callbacks)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithDependentCallbacks.create!
      post.comments_with_callbacks << CommentWithCallbacks.create!
      post.comments_with_callbacks << CommentWithCallbacks.create!

      assert post.destroy
      assert_equal 0, CommentWithCallbacks.count
      assert_equal 2, CommentWithCallbacks.callback_run_count
    end
  end
end
