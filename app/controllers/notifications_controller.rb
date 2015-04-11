class NotificationsController < ApplicationController
  before_action :set_notification, only: [:show, :edit, :update, :destroy]

  skip_before_filter :verify_authenticity_token


  # GET /notifications
  # GET /notifications.json
  def index
    @notifications = Notification.all
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
  end

  # GET /notifications_by_user/1
  def notifications_by_user
    begin
      if params[:user_id]
        notifications = Notification.where(receiver_id: params[:user_id], read: false)
        unless notifications.empty?
          render json: notifications.to_json, status: :ok
        else
          render json: "no notifications", status: :ok
        end
      else
        render json: "wrong params", status: :unprocessable_entity
      end
    rescue
      render json: "error", status: :unprocessable_entity
    end
  end

  # GET /notifications/new
  def new
    @notification = Notification.new
  end

  # GET /notifications/1/edit
  def edit
  end

  # POST /notifications
  # POST /notifications.json
  def create
    @notification = Notification.new(notification_params)
    if @notification.save
      Notifier.send_notification(@notification)
      render json: "Created succesfully", status: :ok
    else
      render json: @notification.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /notifications/1
  # PATCH/PUT /notifications/1.json
  def update
    if @notification.update(notification_params)
      render json: "Successfully updated", status: :ok
    else
      render json: @notification.errors, status: :unprocessable_entity
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification.destroy
    head :no_content 
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.require(:notification).permit(:creator_id, :receiver_id, :post_id, :type, :title, :message, :read)
    end
end
