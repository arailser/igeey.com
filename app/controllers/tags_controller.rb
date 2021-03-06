# encoding: utf-8
class TagsController < InheritedResources::Base
  respond_to :html
  before_filter :login_required, :only => [:new,:create,:destroy,:edit,:update]
  before_filter :find_tag, :except => [:index,:new,:create]
  
  def index
    @tags = Tag.paginate(:page => params[:page], :per_page => 20)
  end
    
  def create
    @tag = Tag.new(params[:tag])
    @tag.save
    respond_with @tag
  end
  
  def show
    @timeline = @tag.taggeds.where(['taggable_type not in (?)',['Question','Tag','Task']]).limit(11).map(&:taggable)
    @questions = @tag.taggeds.where(['taggable_type = ?','Question']).limit(11).map(&:taggable)
    @tasks = @tag.taggeds.where(['taggable_type = ?','Task']).limit(11).map(&:taggable)
    @question = Question.new
    @tags = Tag.find_tagged_with(@tag.name)
  end
      
  def update
    @tag.update_attributes(params[:tag]) 
    respond_with @tag
  end
  
  def questions
    @questions = @tag.taggeds.where(['taggable_type = ?','Question']).paginate(:page => params[:page], :per_page => 10).map(&:taggable)
    @question = Question.new
  end
  
  def timeline
    @timeline = @tag.taggeds.where(['taggable_type != ?','Question']).paginate(:page => params[:page], :per_page => 10).map(&:taggable)
  end
  
  private
  def find_tag
    if /^[\d]*$/.match(params[:id])
      @tag = Tag.find(params[:id])
    else
      @tag = Tag.find_by_name(params[:id])
    end
    render :file => "public/404.html",:status => 404,:layout => false if @tag.nil?
  end
  
end
