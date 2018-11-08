class TransfersController < ApplicationController
  def new
    @transfer = Transfer.new
  end

  def create
    @transfer = Transfer.new(transfer_params)
    if @transfer.save!
      # TransferJob.perform_later(@transfer)
      flash['info'] = "Your transfer has been launched! You'll receive an email as soon as it is done!"
      redirect_to @transfer
    else
      render :new
    end
  end

  def show
    @transfer = Transfer.find(params[:id])
  end

  private

  def transfer_params
    params.require(:transfer).permit(:owner_email, :source_consumer_key,
                                     :source_consumer_secret, :source_token,
                                     :source_token_secret, :source_blog, :source_tag,
                                     :destination_consumer_key, :destination_consumer_secret,
                                     :destination_token, :destination_token_secret,
                                     :destination_blog, :destination_tag)
  end
end
