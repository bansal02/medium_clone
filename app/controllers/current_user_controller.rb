class CurrentUserController < ApplicationController
  before_action :authenticate_user!
  def index
    render json: UserSerializer.new(current_user).serializable_hash[:data][:attributes], status: :ok
  end

  # private
    
  # def authenticate_user!
  #     unless user_signed_in?
  #       render json: { error: 'Please sign in' }, status: :unauthorized
  #     end
  # end
end
