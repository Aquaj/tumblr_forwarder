class TransfersController < ApplicationController
  def new
    @transfer = Transfer.new
  end

  def create
    @transfer = Transfer.new(transfer_params)
    ForwardingJob.perform_now(@transfer)
    flash['info'] = "Your transfer has been launched !"
    redirect_to new_transfers_path
  end

  private

  def transfer_params
    params.require(:transfer).permit(:source_consumer_key, :source_consumer_secret, :source_token, :source_token_secret, :source_blog, :destination_consumer_key, :destination_consumer_secret, :destination_token, :destination_token_secret, :destination_blog, :source_tag)
  end
end
