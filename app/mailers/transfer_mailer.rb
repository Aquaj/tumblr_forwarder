class TransferMailer < ApplicationMailer
  def complete_email
    @transfer = params[:transfer]
    @owner = @transfer.owner_email
    mail(to: @owner, subject: "Transfer complete !") if @owner
  end
end
