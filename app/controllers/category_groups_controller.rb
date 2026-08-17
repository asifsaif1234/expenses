# frozen_string_literal: true

class CategoryGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: %i[show edit update destroy update_position]
  before_action :authorize_group!, only: %i[edit update destroy update_position]

  # GET /category_groups
  def index
    @groups = CategoryGroup.for_user(current_user).ordered
    @group = CategoryGroup.new
  end

  # GET /category_groups/:id
  def show
    respond_to do |format|
      format.html { redirect_to categories_path }
      format.json { render json: @group.as_json(include: :categories) }
      format.turbo_stream { render partial: "group", locals: { group: @group } }
    end
  end

  # GET /category_groups/new
  def new
    @group = CategoryGroup.new
    respond_to do |format|
      format.html { render partial: "form", locals: { group: @group } }
      format.turbo_stream { render partial: "modal_form", locals: { group: @group } }
    end
  end

  # GET /category_groups/:id/edit
  def edit
    respond_to do |format|
      format.html { render partial: "form", locals: { group: @group } }
      format.turbo_stream { render partial: "modal_form", locals: { group: @group } }
    end
  end

  # POST /category_groups
  def create
    @group = CategoryGroup.new(group_params)
    @group.user = current_user
    @group.is_system = false

    if @group.save
      respond_to do |format|
        format.html { redirect_to categories_path, notice: "Group created successfully." }
        format.turbo_stream do
          flash.now[:notice] = "Group created successfully."
          render turbo_stream: [
            turbo_stream.prepend("groups_container", partial: "group", locals: { group: @group }),
            turbo_stream.replace("group_form", partial: "form",
                                locals: { group: CategoryGroup.new }),
            turbo_stream.replace("flash_messages", partial: "shared/flash"),
          ]
        end
        format.json { render json: { success: true, group: @group }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:alert] = "Failed to create group: #{@group.errors.full_messages.join(', ')}"
          render turbo_stream: [
            turbo_stream.replace("group_form", partial: "form", locals: { group: @group }),
            turbo_stream.replace("flash_messages", partial: "shared/flash"),
          ], status: :unprocessable_entity
        end
        format.json { render json: { success: false, errors: @group.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /category_groups/:id
  def update
    if @group.update(group_params)
      respond_to do |format|
        format.html { redirect_to categories_path, notice: "Group updated successfully." }
        format.turbo_stream do
          flash.now[:notice] = "Group updated successfully."
          render turbo_stream: [
            turbo_stream.replace(@group, partial: "group", locals: { group: @group }),
            turbo_stream.replace("flash_messages", partial: "shared/flash"),
          ]
        end
        format.json { render json: { success: true, group: @group } }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:alert] = "Failed to update group: #{@group.errors.full_messages.join(', ')}"
          render turbo_stream: [
            turbo_stream.replace("group_form", partial: "form", locals: { group: @group }),
            turbo_stream.replace("flash_messages", partial: "shared/flash"),
          ], status: :unprocessable_entity
        end
        format.json { render json: { success: false, errors: @group.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /category_groups/:id
  def destroy
    if @group.categories.exists?
      redirect_to categories_path, alert: "Cannot delete group with existing categories."
      return
    end

    @group.destroy!
    respond_to do |format|
      format.html { redirect_to categories_path, notice: "Group deleted successfully." }
      format.turbo_stream do
        flash.now[:notice] = "Group deleted successfully."
        render turbo_stream: [
          turbo_stream.remove(@group),
          turbo_stream.replace("flash_messages", partial: "shared/flash"),
        ]
      end
      format.json { render json: { success: true, message: "Group deleted successfully" } }
    end
  end

  # PATCH /category_groups/:id/update_position
  def update_position
    if @group.update(position: params[:position])
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.json { render json: { success: true } }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.json { render json: { success: false, errors: @group.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_group
    @group = CategoryGroup.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to categories_path, alert: "Group not found."
  end

  def authorize_group!
    unless @group.editable_by?(current_user)
      redirect_to categories_path, alert: "You don't have permission to perform this action."
    end
  end

  def group_params
    params.require(:category_group).permit(:name, :icon, :position)
  end
end
