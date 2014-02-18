(($) ->
  $.fn.assetable_uploader = (options) ->
    
    # Defaults variables
    defaults =
      allow_select_mg: true
      authenticity_token: null
      directions: 'or <a href="/assetable/external_services/new" class="btn-third-party-service">add third party service</a>'
      drag_drop: true
      fieldname: null
      FileUploaded: options.onUploaded
      fileRemoved: options.fileRemoved
      fileUpdated: options.fileUpdated
      gallery: false
      id: null
      max_file_size: options.max_file_size
      multiple_queues: true
      multi_selection: true
      max_file_count: 0
      unique_names: true
      url: null
      uploader_id: null
    
    assetable_uploader = this

    init = ->
      # merge the options with the defaults
      assetable_uploader.options = jQuery.extend({}, defaults, options)
      assetable_uploader.id = assetable_uploader.attr('id')
      bind_uploader()

    
    bind_uploader = ->

      # Create our extra HTML for the copy and queu
      upload_queue = '<ul class="upload-queue"></ul>'
      # Add to the uploader
      $(assetable_uploader).append(upload_queue)


      # Instantiate the uploader
      uploader = new plupload.Uploader(
        runtimes: "html5"
        browse_button: "#{assetable_uploader.id}-browse-btn"
        url: assetable_uploader.options.url
        max_file_size: assetable_uploader.options.max_file_size
        unique_names: assetable_uploader.options.unique_names
        dragdrop: assetable_uploader.options.drag_drop
        drop_element: assetable_uploader.id
        multiple_queues: assetable_uploader.options.multiple_queues
        multi_selection: assetable_uploader.options.multi_selection
        max_file_count: assetable_uploader.options.max_file_count
        multipart: true
        multipart_params:
          authenticity_token: assetable_uploader.options.authenticity_token
          fieldname: assetable_uploader.options.fieldname
          uploader_id: assetable_uploader.options.uploader_id

        # Filter file types
        filters:
          mime_types : [
            title: "Image files"
            extensions: "jpg,gif,png"
          ,
            title: "Video files"
            extensions: "mov,mp4,mpeg4"
          ,
            title: "Zip Files"
            extensions: "zip"
          ]
          max_file_size: assetable_uploader.options.max_file_size
          prevent_duplicates: true
      )  
      
      
      # # Initiate the uploader
      uploader.init()
      
      # Bind to file added function
      uploader.bind "FilesAdded", (up, files) ->
        $.each files, (i, file) ->
          $("ul.upload-queue", assetable_uploader).append '<li id="' + file.id + '"><span class="uploader-file-name">' + file.name + '</span><div class="progress progress"><div class="progress-bar progress-bar-success"></div></div></li>'

          
      # Update the progress bars
      uploader.bind "UploadProgress", (up, file) ->
        $("li#" + file.id + " .progress .progress-bar", assetable_uploader).width file.percent + "%"

      
      # Listen for upload complete
      uploader.bind "FileUploaded", (up, file, info) ->
        if assetable_uploader.options.FileUploaded
          eval(info.response)
          #assetable_uploader.options.FileUploaded json
        $("li#" + file.id, assetable_uploader).fadeOut().remove()

      
      # Listen for queue changes
      uploader.bind "QueueChanged", (up, files) ->
        uploader.start()
        up.refresh()
      
      # # Listen for errors
      uploader.bind "Error", (up, err) ->
        


      draggable_selector = (if assetable_uploader.options.gallery then $('.uploader-directions', assetable_uploader) else $(assetable_uploader))

      # Handle the drag over effect, adds a class to the container
      $(draggable_selector).bind "dragover", ->
        $(this).addClass "droppable" unless $(this).hasClass("droppable")

      # Handles drag leave 
      $(draggable_selector).on "dragleave", ->
        $(this).removeClass "droppable" if $(this).hasClass("droppable")

      $(draggable_selector).on "dragend", ->
        $(this).removeClass "droppable" if $(this).hasClass("droppable")

      $(draggable_selector).on "drop", ->
        $(this).removeClass "droppable" if $(this).hasClass("droppable")




      # Remove asset link handler
      $(assetable_uploader).on "click", ".btn-uploader-remove-asset", (e)->
        e.preventDefault()
        if assetable_uploader.options.fileRemoved
          assetable_uploader.options.fileRemoved this, assetable_uploader


      # $(assetable_uploader).on "click", ".btn-uploader-edit-asset", (e)->
      #   e.preventDefault()
      #   $.ajax
      #     url: $(this).attr('href')
      #     data: {fieldname: assetable_uploader.options.fieldname}
      #     type: 'GET'

      #     success: (response)->
      #       $response = $(response)
      #       $response.modal()

      #       $('form.form-edit-asset').on 'ajax:beforeSend', ()->
      #           # console.log "form submitting..."                

      #       $('form.form-edit-asset').on 'ajax:success', (data, status, xhr)->
      #         if status.success
      #           $response.modal('hide').remove()
      #           assetable_uploader.options.fileUpdated status


      $(assetable_uploader).on "click", ".btn-open-asset-gallery", (e)->
        e.preventDefault()
        $(assetable_uploader).asset_gallery({fieldname: assetable_uploader.options.fieldname})
        # if assetable_uploader.options.openAssetGallery
        #   assetable_uploader.options.openAssetGallery this, assetable_uploader
      
      # $(assetable_uploader).on "click", ".btn-third-party-service", (e)->
      #   e.preventDefault()
      #   console.log "boom"


      # # Add a third party service
      # $(assetable_uploader).on "click", ".btn-third-party-service", (e)->
      #   e.preventDefault()
      #   $.ajax
      #     url: $(this).attr('href')
      #     data: {fieldname: assetable_uploader.options.fieldname}
      #     type: 'GET'

      #     success: (response)->
      #       $response = $(response)
      #       $response.modal()

      #       $('form#new_external_service').on 'ajax:beforeSend', ()->
      #           # console.log "form submitting..."                

      #       $('form#new_external_service').on 'ajax:success', (data, status, xhr)->
      #         if status.success
      #           $response.modal('hide').remove()
      #           assetable_uploader.options.FileUploaded status
                




    init()

) jQuery




bind_uploaders = ->
  # Bind the koh uploader and galleries to a page
  $(".uploader").each ->
    # Check that it's not already bound
    unless $(this).hasClass("uploadable")
      $(this).addClass "uploadable"
      $this = $(this)
      $this.removeClass "uploader"
      
      field = $this.attr("data-uploader-input-name")
      uploader_id = $this.attr('id')

      $this.assetable_uploader
        multi_selection: false
        url: "/assetable/assets.js"
        fieldname: field
        uploader_id: uploader_id
        directions: $this.attr('data-uploader-directions')
        max_file_size: $this.attr("data-max-file-size")
        authenticity_token: $("meta[name=\"csrf-token\"]").attr("content")
        onUploaded: (resp) ->
          # $this.find('.uploader-data-wrapper').html(resp.html)
          # $this.addClass("uploader-has-asset")
        fileRemoved: (button, item) ->
          return false unless $(item).hasClass("uploader-has-asset")
          $('.uploader-preview', item).html('<input type="hidden" name="' + field + '" />')
          $(item).removeClass("uploader-has-asset")
        fileUpdated: (resp) ->
          $this.find('div.uploader-preview[data-asset-id="' + resp.id + '"]').replaceWith(resp.html)
        # openAssetGallery: (button, item) ->



window.Assetable.bind_uploaders = bind_uploaders

$(document).ready ->
            
  window.Assetable.bind_uploaders()

  # Remove assetable modals on close
  $(document).on "hidden.bs.modal", ".assetable-modal", ->
    $(this).remove()
    return
