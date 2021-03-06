# encoding: utf-8
class Record < ActiveRecord::Base
  belongs_to :user,     :counter_cache => true
  belongs_to :venue,    :counter_cache => true
  belongs_to :task
  belongs_to :plan
  belongs_to :parent,   :class_name => :record,:foreign_key => :parent_id
  has_many   :comments, :as => :commentable,    :dependent => :destroy
  has_many   :follows,  :as => :followable,     :dependent => :destroy
  has_many   :syncs,    :as => :syncable,       :dependent => :destroy
  has_many   :photos,   :as => :imageable,      :dependent => :destroy
  has_many   :notifications, :as => :notifiable, :dependent => :destroy

  default_scope :order => 'created_at DESC'

  has_attached_file :cover, :styles => {:_90x64 => ["90x64#"],:max500x400 => ["500x400>"]},
    :url=>"/media/:attachment/records/:id/:style.:extension",
    :default_style=> :_90x64,
    :default_url=>"/defaults/:attachment/record/:style.png"

  delegate  :for_what, :to => :task

  acts_as_ownable
  acts_as_taggable

  accepts_nested_attributes_for :photos

  validates :user_id, :presence => true, :uniqueness => { :scope => [:plan_id] }
  validates_presence_of :title, :task_id, :detail, :plan_id, :venue_id

  def number
    { 'money'=> money,'goods'=> goods,'time'=> time,'online' => online }[for_what] || 0
  end

  def formatted_done_at
    date = self.done_at
    "#{date.year == Date.today.year ? '' : "#{date.year}年"}#{date.month}月#{date.day}日"
  end

  def description
    "完成了在#{self.venue.name}的行动：#{self.title}"
  end

  def is_done
    true
  end

  def for_what
    { 1=>'time', 3=>'goods' }[actional_id]
  end

end
