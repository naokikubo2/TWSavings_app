class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  attr_accessor :current_password
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :hourly_pay, presence: true, length: { maximum: 6 }

  has_many :undone_actions, dependent: :destroy
  has_many :savings_records, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverse_of_relationships, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverse_of_relationships, source: :user

  def follow(other_user_id)
      self.relationships.find_or_create_by(follow_id: other_user_id) unless self.id == other_user_id.to_i
  end

  def unfollow(other_user_id)
    relationship = self.relationships.find_by(follow_id: other_user_id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end

  def feed
    following_ids = "SELECT follow_id FROM relationships
                     WHERE user_id = :user_id"
    SavingsRecord.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end
end
