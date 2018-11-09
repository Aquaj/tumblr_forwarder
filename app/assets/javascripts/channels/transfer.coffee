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
        total = parseFloat(transfer.total)
        current = parseFloat(transfer.current)
        percentage ||= (current / total) * 50
        progressBar.removeClass('bg-success')
        progressBar.addClass('progress-bar-striped progress-bar-animated')
        progressBar.attr('style', "width: #{percentage}%")
        progressBar.text("#{Math.round(percentage)}%")

      updateReblog: (transfer) ->
        percentage = 100 if transfer.total == 0
        total = parseFloat(transfer.total)
        remaining = parseFloat(transfer.current)
        current = (total - current)
        percentage ||= (current / total) * 50
        progressBar.attr('style', "width: #{50 + percentage}%")
        if (50+percentage < 100)
          progressBar.removeClass('bg-success')
          progressBar.addClass('progress-bar-striped progress-bar-animated')
          progressBar.text("#{Math.round(50 + percentage)}%")
        else
          progressBar.addClass('bg-success')
          progressBar.removeClass('progress-bar-striped')
          progressBar.text("Transfer complete!")
