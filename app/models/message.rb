class Message < ActiveRecord::Base
  belongs_to :from_user, :class_name => "User", :foreign_key => "from_user_id"
  belongs_to :to_user,   :class_name => "User", :foreign_key => "to_user_id"

  default_scope :order => 'created_at DESC'

  validates :from_user_id, :to_user_id, :content, :presence => true

  def read
    self.update_attribute(:unread, false)
  end
end
