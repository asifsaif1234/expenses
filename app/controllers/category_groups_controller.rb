# app/controllers/category_groups_controller.rb
class CategoryGroupsController < ApplicationController
  before_action :set_group, only: [:edit, :update, :destroy, :update_position]
  
  def index
    @groups = CategoryGroup.for_user(current_user).ordered
    @group = CategoryGroup.new
  end
  
  def create
    @group = CategoryGroup.new(group_params)
    @group.user = current_user
    @group.is_system = false
    
    if @group.save
      redirect_to categories_path, notice: "Group created successfully."
    else
      @groups = CategoryGroup.for_user(current_user).ordered
      render :index, status: :unprocessable_entity
    end
  end
  
  def update
    if @group.system_group?
      redirect_to categories_path, alert: "System groups cannot be modified."
      return
    end
    
    if @group.update(group_params)
      redirect_to categories_path, notice: "Group updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    if @group.system_group?
      redirect_to categories_path, alert: "System groups cannot be deleted."
      return
    end
    
    if @group.categories.exists?
      redirect_to categories_path, alert: "Cannot delete group with existing categories."
    else
      @group.destroy
      redirect_to categories_path, notice: "Group deleted successfully."
    end
  end
  
  def update_position
    if @group.update(position: params[:position])
      head :ok
    else
      head :unprocessable_entity
    end
  end
  
  private
  
  def set_group
    @group = CategoryGroup.find(params[:id])
  end
  
  def group_params
    params.require(:category_group).permit(:name, :icon, :position)
  end
end