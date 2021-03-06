# encoding: utf-8
class VenuesController < InheritedResources::Base
  respond_to :html,:json
  before_filter :login_required, :except => [:index, :show, :records, :followers, :more_items, :position, :watching]
  before_filter :find_venue, :except => [:index, :new, :create]
  
  def index
    @venues_hash = {}
    @categories = Venue::CATEGORIES_HASH.to_a[0..5]
    @categories.each do |k,v|
      @venues_hash[v.to_sym] = Venue.where(:category => k).limit(6)
    end
    @venues = Venue.limit(9).where(:created_at => 1.month.ago..Date.today)
  end
  
  def create
    @venue = Venue.new(params[:venue])
    @venue.creator = current_user
    @venue.init_geocodding
    flash[:notice] = 'Venue was successfully created.' if @venue.save
    respond_with(@venue)
  end
  
  def show
    @tasks = @venue.tasks.limit(11)
    @photos = @venue.photos.limit(11)
    @sayings = @venue.sayings.limit(11)
    @topics = @venue.topics.limit(11)
    @timeline = @venue.events.limit(11)
    @followers = @venue.followers.limit(8)
    
    @saying = Saying.new 
    @photo = Photo.new 
    @task = Task.new 
    @topic = Topic.new
    @doing = Doing.new
  end
  
  def more_items
    if ['photos','sayings','topics','tasks'].include?(params[:filter])
      @items = @venue.send(params[:filter]).paginate(:page => params[:page], :per_page => 10)
      @filter = params[:filter]
      render '/public/more_items',:layout => false
    else
      @timeline = @venue.events.paginate(:page => params[:page], :per_page => 10)
      render '/public/more_timeline',:layout => false
    end
  end
    
  def update
    @venue.update_attributes(params[:venue]) if @venue.creator == current_user
    if params[:back_path].present?
      redirect_to params[:back_path]
    else
      respond_with(@venue)
    end
  end

  def cover
    render :layout => false if params[:layout] == 'false'
  end
  
  def position
    render :layout => false if params[:layout] == 'false'
  end
  
  def records
    @items = @venue.records.paginate(:page => params[:page], :per_page => 10)
    @title = "#{@venue.name}的行动记录"
    render 'see_all'
  end
  
  def tasks
    @items = @venue.tasks.paginate(:page => params[:page], :per_page => 10)
    @title = "#{@venue.name}的任务"
    render 'see_all'
  end
  
  def topics
    @items = @venue.topics.paginate(:page => params[:page], :per_page => 10)
    @title = "#{@venue.name}的故事"
    render 'see_all'
  end
  
  def sayings
    @items = @venue.sayings.paginate(:page => params[:page], :per_page => 10)
    @title = "#{@venue.name}的报到"
    render 'see_all'
  end
  
  def photos
    @items = @venue.photos.paginate(:page => params[:page], :per_page => 10)
    @title = "#{@venue.name}的照片"
    render 'see_all'
  end

  def doings
    @items = @venue.doings.paginate(:page => params[:page], :per_page => 10)
    @title = "#{@venue.name}的行动"
    render 'see_all'
  end
  
  def followers
    @items = @venue.followers.paginate(:page => params[:page], :per_page => 10)
    @title = "#{@venue.name}的关注者"
    render 'see_all'
  end
  
  def watching
    @venue.update_attribute(:watch_count,(@venue.watch_count + 1))
    render :text => 'OK'
  end
  
  private
  def find_venue
    @venue = Venue.find(params[:id])
  end
end
