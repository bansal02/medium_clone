class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session
    before_action :authenticate_user!, unless: :skip_authentication?

    private

    def skip_authentication?
        request.get?
    end

    # private

    # def authenticate_user!
    #     unless user_signed_in?
    #       render json: { error: 'Please sign in' }, status: :unauthorized
    #     end
    # end
end
