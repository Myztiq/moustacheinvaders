$document = $(document)
$document.ready ()->
  window.backProjectionOpactiy = .3
  videoInput = $('video')[0];
  $canvasInput = $('.tracking');
  canvasInput = $canvasInput[0];
  $gameCanvas = $('.game');
  gameCanvas = $gameCanvas[0];
  gameCanvasCtx = gameCanvas.getContext('2d')
  $moustache = $('.moustache');
  moustache = $moustache[0]
  ctx = canvasInput.getContext('2d');

  gameWidth = $gameCanvas.width()

  htracker = new headtrackr.Tracker({calcAngles : false, ui : true});
  htracker.init(videoInput, canvasInput);
  htracker.start();


  pixelator = document.createElement('canvas')

  $document.one 'facetrackingEvent', (e)->
    startGame(e.originalEvent.x / gameWidth)

  $document.on 'facetrackingEvent', (e)->
    faceData =
      x: e.originalEvent.x
      y: e.originalEvent.y
      width: e.originalEvent.width
      height: e.originalEvent.height

    updatePosition((faceData.x - faceData.width / 2))

    # Figure out the position and draw the moustache
    mWidth = faceData.width - faceData.width / 3
    mHeight = mWidth / $moustache.width() * $moustache.height()
    xPos = faceData.x - mWidth / 2
    yPos = faceData.y
    ctx.drawImage(moustache, xPos, yPos, mWidth, mHeight)

    padding = 20;
    fWidth = faceData.width + padding*2 #Face Width
    fHeight =  faceData.height + padding*2 #Face Height

    imgData = ctx.getImageData(faceData.x - faceData.width / 2 - padding, faceData.y - faceData.height / 2 - padding, fWidth, fHeight)

    pixelWidth = imgData.width * 4
    pixelHeigh = imgData.height

    # We want to fade the edges out of their "face"
    for val, i in imgData.data by 4
      index = i + 3

      # Check to see how close they are to the center and fade based on that
      # Pixels are 4 in length

      horizontalFactor = Math.abs( .5 - Math.abs((index % pixelWidth) - pixelWidth / 2) / pixelWidth )
      row = Math.floor index/pixelWidth

      verticalFactor =  Math.abs( .5 - Math.abs((row % pixelHeigh) - pixelHeigh / 2) / pixelHeigh )

      horizontalFactor *= 2
      verticalFactor *= 2
      lowest = horizontalFactor
      if horizontalFactor > verticalFactor
        lowest = verticalFactor

      imgData.data[index] = lowest * 255;

    # Pixelize this stuf
    pixelize imgData, (imgData)->

      # Reverse the positioning!
      reverse = gameWidth/2 - (faceData.x + faceData.width / 2)
      # Clear the canvas
      gameCanvas.width = gameCanvas.width
      # Draw our pixilized data
      gameCanvasCtx.putImageData(imgData, reverse, 0)
      encoder.add(canvasInput)

  encoder = new Whammy.Video(20);

  startGame = (x)->
    console.log 'Starting game', x

  updatePosition = (x)->
    #    console.log 'Moving to ', x

  $('.savevVideo').click ()->
    endGame()

  endGame = ()->
    output = encoder.compile();
    url = (window.webkitURL || window.URL).createObjectURL(output);
    $recordedVideo = $('.recordedVideo')
    $recordedVideo.show().attr 'src', url
    $recordedVideo.after('<a href="'+url+'" download="FaceInvaders.webm">Download</a>')



  pixelize = (imgData, cb)->
    canvas = $('<canvas></canvas>')[0]
    canvas.width = imgData.width
    canvas.height = imgData.height
    pixelizeCtx = canvas.getContext('2d')
    pixelizeCtx.putImageData(imgData, 0, 0)

    img = $('<img class="pixelator">')
    $('.pixelator').replaceWith(img)
    img.attr 'src', canvas.toDataURL()
    img.css
      width: imgData.width
      height: imgData.height
    img.on 'load', ()->
      img[0].closePixelate([
        { resolution : 4 }
      ])
      canvas.width = canvas.width
      newImgData = $('.pixelator')[0].getContext('2d').getImageData(0, 0, imgData.width, imgData.height)
      cb newImgData