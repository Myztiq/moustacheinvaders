$document = $(document)
$document.ready ()->
  videoInput = $('video')[0];
  debugCanvas = $('.debug')[0];
  canvasInput = $('.game')[0];
  $moustache = $('.moustache');
  moustache = $moustache[0]
  debugCtx = canvasInput.getContext('2d');
  ctx = debugCanvas.getContext('2d');



  htracker = new headtrackr.Tracker({calcAngles : true, ui : true, debug: debugCanvas});
  htracker.init(videoInput, canvasInput);
  htracker.start();

  $document.on 'facetrackingEvent', (e)->
    faceData =
      x: e.originalEvent.x
      y: e.originalEvent.y
      width: e.originalEvent.width
      height: e.originalEvent.height
      angle: e.originalEvent.angle - Math.PI / 2


    mWidth = faceData.width - faceData.width / 5
    mHeight = mWidth / $moustache.width() * $moustache.height()


    xPos = faceData.x - mWidth / 2
    yPos = faceData.y
    drawOnCanvas (ctx)->
      ctx.translate(xPos, yPos)
      ctx.drawImage(moustache, 0, 0, mWidth, mHeight)
      ctx.translate(-xPos, -yPos)

  drawOnCanvas = (cb)->
    cb(debugCtx)
    cb(ctx)