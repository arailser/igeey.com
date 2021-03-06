# encoding: utf-8
class TasksController < InheritedResources::Base
  respond_to :html
  before_filter :login_required, :except => [:index, :show, :progress, :more]
  before_filter :find_task, :except => [:index, :new, :create, :more]
  
  def create
    @task = current_user.tasks.build(params[:task])
    if @task.save
      flash[:dialog] = "<a href='#{new_sync_path}?syncable_type=#{@task.class}&syncable_id=#{@task.id}' class='open_dialog' title='传播这个任务'>同步</a>" 
    end
    respond_with @task
  end

  def show
    @task = Task.find(params[:id])
    @venue = @task.venue
    @plans = @task.plans
    @my_plan = current_user.plans.select{|p| p.task_id == @task.id}.first if logged_in? # user`s plan on this task
    @followers = @task.followers.limit(8)
    @comments = @task.comments
    @tasks = @task.related_tasks
  end
  
  def update
    @task.update_attributes(params[:task])
    if params[:back_path].present?
      redirect_to params[:back_path]
    else
      respond_with @task
    end
  end
  
  def close
    @task.update_attributes(:close => true) if @task.owned_by?(current_user)
    respond_with @task
  end
  
  def progress
    @records = @task.records
  end
  
  def more
    @items = Task.paginate(:page => params[:page], :per_page => 6)
    render '/public/more_items',:layout => false
  end
  
  private
  def find_task
    @task = Task.find(params[:id])
  end
  
end
