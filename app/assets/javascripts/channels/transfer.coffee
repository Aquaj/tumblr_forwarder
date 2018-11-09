$(document).on 'turbolinks:load', ->
  $('#transfer-progress').each ->
    id = $(this).data('transfer-id')
    progressBar = $(this)
    App.cable.subscriptions.create { channel: "TransferChannel", id: id },
      connected: ->
        # Called when the subscription is ready for use on the server

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (transfer) ->
        type = transfer.type
        if type == "fetch"
          @updateFetch(transfer)
        else
          @updateReblog(transfer)

      updateFetch: (transfer) ->
        percentage = 50 if transfer.total == 0
        percentage ||= parseFloat(transfer.current) / parseFloat(transfer.total) * 50
        progressBar.attr('style', "width: #{percentage}%")

      updateReblog: (transfer) ->
        percentage = 100 if transfer.total == 0
        percentage ||= 50 + parseFloat(transfer.current) / parseFloat(transfer.total) * 50
        progressBar.attr('style', "width: #{percentage}%")
