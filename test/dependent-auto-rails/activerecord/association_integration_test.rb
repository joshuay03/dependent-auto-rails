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

class PostWithDependentCallbacks < Post
  has_one :comment_with_find_callback, foreign_key: :post_id, dependent: :auto
  has_many :comments_with_find_callback, class_name: :CommentWithFindCallback, foreign_key: :post_id, dependent: :auto

  has_one :comment_with_initialize_callback, foreign_key: :post_id, dependent: :auto
  has_many :comments_with_initialize_callback, class_name: :CommentWithInitializeCallback, foreign_key: :post_id, dependent: :auto

  has_one :comment_with_destroy_callback, foreign_key: :post_id, dependent: :auto
  has_many :comments_with_destroy_callback, class_name: :CommentWithDestroyCallback, foreign_key: :post_id, dependent: :auto

  has_one :comment_with_commit_callback, foreign_key: :post_id, dependent: :auto
  has_many :comments_with_commit_callback, class_name: :CommentWithCommitCallback, foreign_key: :post_id, dependent: :auto

  has_one :comment_with_rollback_callback, foreign_key: :post_id, dependent: :auto
  has_many :comments_with_rollback_callback, class_name: :CommentWithRollbackCallback, foreign_key: :post_id, dependent: :auto
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class CommentWithFindCallback < Comment
  belongs_to :post_with_dependent_callbacks

  after_find {}
end

class CommentWithInitializeCallback < Comment
  belongs_to :post_with_dependent_callbacks

  after_initialize {}
end

class CommentWithDestroyCallback < Comment
  belongs_to :post_with_dependent_callbacks

  after_destroy {}
end

class CommentWithCommitCallback < Comment
  belongs_to :post_with_dependent_callbacks

  after_destroy_commit {}
end

class CommentWithRollbackCallback < Comment
  belongs_to :post_with_dependent_callbacks

  after_rollback {}
end

# ---------- End ActiveRecord Setup ----------

class AssociationIntegrationTest < Minitest::Test
  def setup
    Post.delete_all
    Comment.delete_all
  end

  class SingularAssociationIntegrationTest < AssociationIntegrationTest
    def test_dependent_auto
      post = Post.create!(comment: Comment.create!)

      assert_nothing_raised { post.destroy! }
      assert_equal 0, Comment.count
    end

    def test_dependent_auto_without_callback
      association = Post.reflect_on_association(:comment)
      assert_equal :delete, association.options[:dependent]

      post = Post.create!(comment: Comment.create!)

      assert post.destroy
      assert_equal 0, Comment.count
    end

    def test_dependent_auto_with_find_callback
      association = PostWithDependentCallbacks.reflect_on_association(:comment_with_find_callback)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithDependentCallbacks.create!(comment_with_find_callback: CommentWithFindCallback.create!)

      assert post.destroy
      assert_equal 0, CommentWithFindCallback.count
    end

    def test_dependent_auto_with_initialize_callback
      association = PostWithDependentCallbacks.reflect_on_association(:comment_with_initialize_callback)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithDependentCallbacks.create!(comment_with_initialize_callback: CommentWithInitializeCallback.create!)

      assert post.destroy
      assert_equal 0, CommentWithInitializeCallback.count
    end

    def test_dependent_auto_with_destroy_callback
      association = PostWithDependentCallbacks.reflect_on_association(:comment_with_destroy_callback)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithDependentCallbacks.create!(comment_with_destroy_callback: CommentWithDestroyCallback.create!)

      assert post.destroy
      assert_equal 0, CommentWithDestroyCallback.count
    end

    def test_dependent_auto_with_commit_callback
      association = PostWithDependentCallbacks.reflect_on_association(:comment_with_commit_callback)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithDependentCallbacks.create!(comment_with_commit_callback: CommentWithCommitCallback.create!)

      assert post.destroy
      assert_equal 0, CommentWithCommitCallback.count
    end

    def test_dependent_auto_with_rollback_callback
      association = PostWithDependentCallbacks.reflect_on_association(:comment_with_rollback_callback)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithDependentCallbacks.create!(comment_with_rollback_callback: CommentWithRollbackCallback.create!)

      assert post.destroy
      assert_equal 0, CommentWithRollbackCallback.count
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

    def test_dependent_auto_without_callback
      association = Post.reflect_on_association(:comments)
      assert_equal :delete_all, association.options[:dependent]

      post = Post.create!
      post.comments << Comment.create!
      post.comments << Comment.create!

      assert post.destroy
      assert_equal 0, Comment.count
    end

    def test_dependent_auto_with_find_callback
      association = PostWithDependentCallbacks.reflect_on_association(:comments_with_find_callback)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithDependentCallbacks.create!
      post.comments_with_find_callback << CommentWithFindCallback.create!
      post.comments_with_find_callback << CommentWithFindCallback.create!

      assert post.destroy
      assert_equal 0, CommentWithFindCallback.count
    end

    def test_dependent_auto_with_initialize_callback
      association = PostWithDependentCallbacks.reflect_on_association(:comments_with_initialize_callback)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithDependentCallbacks.create!
      post.comments_with_initialize_callback << CommentWithInitializeCallback.create!
      post.comments_with_initialize_callback << CommentWithInitializeCallback.create!

      assert post.destroy
      assert_equal 0, CommentWithInitializeCallback.count
    end

    def test_dependent_auto_with_destroy_callback
      association = PostWithDependentCallbacks.reflect_on_association(:comments_with_destroy_callback)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithDependentCallbacks.create!
      post.comments_with_destroy_callback << CommentWithDestroyCallback.create!
      post.comments_with_destroy_callback << CommentWithDestroyCallback.create!

      assert post.destroy
      assert_equal 0, CommentWithDestroyCallback.count
    end

    def test_dependent_auto_with_commit_callback
      association = PostWithDependentCallbacks.reflect_on_association(:comments_with_commit_callback)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithDependentCallbacks.create!
      post.comments_with_commit_callback << CommentWithCommitCallback.create!
      post.comments_with_commit_callback << CommentWithCommitCallback.create!

      assert post.destroy
      assert_equal 0, CommentWithCommitCallback.count
    end

    def test_dependent_auto_with_rollback_callback
      association = PostWithDependentCallbacks.reflect_on_association(:comments_with_rollback_callback)
      assert_equal :destroy, association.options[:dependent]

      post = PostWithDependentCallbacks.create!
      post.comments_with_rollback_callback << CommentWithRollbackCallback.create!
      post.comments_with_rollback_callback << CommentWithRollbackCallback.create!

      assert post.destroy
      assert_equal 0, CommentWithRollbackCallback.count
    end
  end
end
