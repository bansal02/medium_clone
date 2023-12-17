require 'json'
require 'razorpay'

class PaymentsController < ApplicationController
    def pay
        unless current_user
            render json: {message: "Sign up or log in"}, status: :unauthorized
            return
        end

        amount=params.fetch(:amount)
        unless amount
            render json: {message: "Enter amount"}, status: :unprocessable_entity
            return
        end

        amount=amount.to_i

        user_status=Status.find_or_create_by(username: current_user.username)
        current_class=user_status.views
        if amount>current_class
            user_status.views=amount
        end
        user_status.subscription_date=Date.today
        user_status.save
        render json: {message: "your allowed view counts have been upgraded"}, status: :ok
    end


    # In the below section : How the payments controller would have looked if Razorpay is used. Due to limitations of 
    # integrating with frontend, dummy payment is used (above code) so that the logic of subscriptions and throttling can be demonstrated.


    # def generate_unique_order_id
    #     timestamp = Time.now.to_i.to_s 
    #     random_number = SecureRandom.hex(4) 

    #     order_id = "#{timestamp}-#{random_number}" #generating an unique order id
    # end


    # def create_payment

    #     unless current_user
    #         render json: {message: "Sign up or log in"}, status: :unauthorized
    #         return
    #     end
    
    #     amount=params.fetch(:amount)
    #     unless amount
    #         render json: {message: "Enter amount"}, status: :unprocessable_entity
    #         return
    #     end
    #     amount=amount.to_i
    #     currency = 'INR'

    #     order_id = generate_unique_order_id

    #     payment_order = Razorpay::Order.create(
    #         amount: amount,
    #         currency: currency,
    #         receipt: order_id
    #     )

    #     render json: payment_order
    # end


    # def handle_payment_callback
    #     payload = request.body.read
    #     signature = request.headers['X-Razorpay-Signature']

    #     if Razorpay::Utility.verify_webhook_signature(payload, signature, YOUR_RAZORPAY_KEY_SECRET)
    #         data = JSON.parse(payload)

    #         status = data['status']
    #         order_id = data['order_id']

            
    #         payment = Razorpay::Payment.fetch(data['payment_id'])

    #         if status == 'paid' && payment['status'] == 'captured'
    #             # Payment successful
    #             user_status=Status.find_or_create_by(username: current_user.username)
                
    #             current_class=user_status.views
                
    #             amount_paid = payment['amount']

    #             if amount_paid>current_class
    #                 user_status.views=amount_paid
    #             end

    #             user_status.subscription_date=Date.today
    #             user_status.save
    #             render json: {message: "your allowed view counts have been upgraded"}, status: :ok

    #             head :ok
    #         else
    #             # Payment failed or invalid status, handle the error
    #             render json: { error: "Payment failed or invalid status" }, status: :unprocessable_entity

    #             head :bad_request
    #         end
    #     else
    #             # Invalid signature, handle the error
    #             render json: { error: "Invalid signature" }, status: :unprocessable_entity
                
    #             head :bad_request
    #     end
    # end

end
