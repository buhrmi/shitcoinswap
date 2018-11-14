class OrdersChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'orders', coder: ActiveSupport::JSON do |message|
      if params[:base_asset_ids].try(:include?, message['base_asset_id'])
        message.delete('user_id')
        transmit(message)
      elsif message['user_id'] == current_user.id
        transmit(message)
      end
    end
  end
end