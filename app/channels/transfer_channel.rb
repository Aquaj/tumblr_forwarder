class TransferChannel < ApplicationCable::Channel
  def subscribed
    transfer = Transfer.find(params[:id])
    stream_for transfer
  end
end
