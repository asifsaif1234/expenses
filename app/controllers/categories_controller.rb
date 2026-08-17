# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [ :show, :edit, :update, :destroy, :toggle_active ]
  before_action :set_groups, only: [ :new, :create, :edit, :update ]
  before_action :authorize_user!, only: [ :edit, :update, :destroy, :toggle_active ]

  # GET /categories
  def index
    @categories = Category.includes(:category_group)
                          .system_or_user(current_user)
                          .active
                          .ordered
                          .by_group
    @category = Category.new
    @category_group = CategoryGroup.new
    @groups = CategoryGroup.for_user(current_user).ordered
  end

  # GET /categories/grouped
  def grouped
    @grouped_categories = Category.grouped_by_group(current_user)
    render partial: "grouped_categories", locals: { grouped_categories: @grouped_categories }
  end

  # GET /categories/system
  def system
    @categories = Category.system.active.ordered
    render partial: "categories_list", locals: { categories: @categories, title: "System Categories" }
  end

  # GET /categories/user_categories
  def user_categories
    @categories = current_user.categories.active.ordered
    render partial: "categories_list", locals: { categories: @categories, title: "Your Categories" }
  end

  # GET /categories/:id
  def show
    respond_to do |format|
      format.html { redirect_to categories_path }
      format.json { render json: @category.as_json(include: :category_group) }
      format.turbo_stream { render partial: "category", locals: { category: @category } }
    end
  end

  # GET /categories/new
  def new
    @category = Category.new
    @groups = CategoryGroup.for_user(current_user).ordered

    respond_to do |format|
      format.html { render partial: "form", locals: { category: @category, groups: @groups } }
      format.turbo_stream { render partial: "modal_form", locals: { category: @category, groups: @groups } }
    end
  end

  # GET /categories/:id/edit
  def edit
    @groups = CategoryGroup.for_user(current_user).ordered

    respond_to do |format|
      format.html { render partial: "form", locals: { category: @category, groups: @groups } }
      format.turbo_stream { render partial: "modal_form", locals: { category: @category, groups: @groups } }
    end
  end

  # POST /categories
  def create
    @category = Category.new(category_params)
    @category.user = current_user unless params[:category][:is_system] == "true"

    if @category.save
      respond_to do |format|
        format.html { redirect_to categories_path, notice: "Category created successfully." }
        format.turbo_stream do
          flash.now[:notice] = "Category created successfully."
          render turbo_stream: [
            turbo_stream.prepend("categories_list", partial: "category", locals: { category: @category }),
            turbo_stream.replace("flash_messages", partial: "shared/flash"),
            turbo_stream.replace("category_form", partial: "form",
                                locals: { category: Category.new, groups: @groups }),
          ]
        end
        format.json { render json: { success: true, category: @category }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:alert] = "Failed to create category: #{@category.errors.full_messages.join(', ')}"
          render turbo_stream: [
            turbo_stream.replace("category_form", partial: "form",
                                locals: { category: @category, groups: @groups }),
            turbo_stream.replace("flash_messages", partial: "shared/flash"),
          ], status: :unprocessable_entity
        end
        format.json { render json: { success: false, errors: @category.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/:id
  def update
    if @category.update(category_params)
      respond_to do |format|
        format.html { redirect_to categories_path, notice: "Category updated successfully." }
        format.turbo_stream do
          flash.now[:notice] = "Category updated successfully."
          render turbo_stream: [
            turbo_stream.replace(@category, partial: "category", locals: { category: @category }),
            turbo_stream.replace("flash_messages", partial: "shared/flash"),
          ]
        end
        format.json { render json: { success: true, category: @category } }
      end
    else
      @groups = CategoryGroup.for_user(current_user).ordered
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          flash.now[:alert] = "Failed to update category: #{@category.errors.full_messages.join(', ')}"
          render turbo_stream: [
            turbo_stream.replace("category_form", partial: "form",
                                locals: { category: @category, groups: @groups }),
            turbo_stream.replace("flash_messages", partial: "shared/flash"),
          ], status: :unprocessable_entity
        end
        format.json { render json: { success: false, errors: @category.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/:id
  def destroy
    @category.destroy!

    respond_to do |format|
      format.html { redirect_to categories_path, notice: "Category deleted successfully." }
      format.turbo_stream do
        flash.now[:notice] = "Category deleted successfully."
        render turbo_stream: [
          turbo_stream.remove(@category),
          turbo_stream.replace("flash_messages", partial: "shared/flash"),
        ]
      end
      format.json { render json: { success: true, message: "Category deleted successfully" } }
    end
  end

  # PATCH /categories/:id/toggle_active
  def toggle_active
    @category.update!(is_active: !@category.is_active)
    status = @category.is_active ? "activated" : "deactivated"

    respond_to do |format|
      format.html { redirect_to categories_path, notice: "Category #{status} successfully." }
      format.turbo_stream do
        flash.now[:notice] = "Category #{status} successfully."
        render turbo_stream: [
          turbo_stream.replace(@category, partial: "category", locals: { category: @category }),
          turbo_stream.replace("flash_messages", partial: "shared/flash"),
        ]
      end
      format.json { render json: { success: true, is_active: @category.is_active } }
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to categories_path, alert: "Category not found."
  end

  def set_groups
    @groups = CategoryGroup.for_user(current_user).ordered
  end

  def authorize_user!
    unless @category.editable_by?(current_user)
      redirect_to categories_path, alert: "You don't have permission to perform this action."
    end
  end

  def category_params
    params.require(:category).permit(
      :name,
      :icon,
      :color,
      :description,
      :category_group_id,
      :is_active
    )
  end
end
