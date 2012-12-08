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
    # Clear the canvas
    faceData =
      x: e.originalEvent.x
      y: e.originalEvent.y
      width: e.originalEvent.width
      height: e.originalEvent.height

    updatePosition((faceData.x - faceData.width / 2))

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

    for val, i in imgData.data by 4
      index = i + 3

      # We want to fade the edges out of their "face"
      # Check to see how close they are to the center and fade based on that
      # Pixels are 4 in length

      horizontalFactor = Math.abs( .5 - Math.abs((index % pixelWidth) - pixelWidth / 2) / pixelWidth )
      row = Math.floor index/pixelWidth

      verticalFactor =  Math.abs( .5 - Math.abs((row % pixelHeigh) - pixelHeigh / 2) / pixelHeigh )

#      if (index-3) / pixelWidth == Math.round (index-3) / pixelWidth
#        console.log row, verticalFactor

#      if index < pixelWidth
#        console.log horizontalFactor

      horizontalFactor *= 2
      verticalFactor *= 2
      lowest = horizontalFactor
      if horizontalFactor > verticalFactor
        lowest = verticalFactor

      imgData.data[index] = lowest * 255;

    pixelize imgData, (imgData)->

      # Reverse the positioning!
      reverse = gameWidth/2 - (faceData.x + faceData.width / 2)
      gameCanvas.width = gameCanvas.width
      gameCanvasCtx.putImageData(imgData, reverse, 0)

  startGame = (x)->
#    console.log 'Starting game', x

  updatePosition = (x)->
#    console.log 'Moving to ', x


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