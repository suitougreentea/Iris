b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
class @Renderer
  
  init: ->
    @s = document.getElementById("screen").getContext("2d")
    @setclip()
    @s.save()

  setclip: ->
    @s.beginPath()
    @s.moveTo(0, 0)
    @s.lineTo(480, 0)
    @s.lineTo(480, 640)
    @s.lineTo(0, 640)
    @s.clip()

  resize: (size) ->
    result = {}
    if size.width / size.height < 480 / 640
      result.x = 0
      result.y = (size.height - ((size.width / 480) * 640)) / 2
      result.zoom = size.width/480
    else
      result.x = (size.width - ((size.height / 640) * 480)) / 2
      result.y = 0
      result.zoom = size.height/640
    @s.restore()
    @s.translate(result.x, result.y)
    @s.scale(result.zoom, result.zoom)
    @setclip()
    @s.save()
    return result

  render: () ->
    @s.clearRect(0,0,480,640)
    #@s.lineWidth = 1
    #@s.fillStyle = "rgba(0,0,0,0.2)"
    @s.strokeStyle = "rgba(0,0,0,0.2)"
    @drawGrid(@s)
    @s.strokeStyle = "rgba(0, 0, 0, 1)"
    @s.strokeRect(0, 0, 480, 640)

    b = iris.field.world.GetBodyList()
    while(b)
      data = b.GetUserData()
      if data
        if data.type == "wall" or data.type == "floor" or data.type == "ceil"
          @s.fillStyle = "rgba(128, 128, 128, 1)"
          @fillPolygon(@s, b)
        if data.type == "shoot"
          @s.fillStyle = "rgba(0, 0, 0, 1)"
          @fillPolygon(@s, b)
        if data.type == "shape"
          color = iris.config.color[data.color]
          if data.state == iris.const.STATE_FALLING
            @s.fillStyle = "rgba(#{color[0]}, #{color[1]}, #{color[2]}, 0.7)"
          else if data.state == iris.const.STATE_ACTIVE
            @s.fillStyle = "rgba(#{color[0]}, #{color[1]}, #{color[2]}, 1)"
          else if data.state == iris.const.STATE_MATCH
            @s.fillStyle = "rgba(#{color[0] + 64}, #{color[1] + 64}, #{color[2]}, 1)"
          else if data.state == iris.const.STATE_INACTIVE
            @s.fillStyle = "rgba(#{color[0] - 64}, #{color[1] - 64}, #{color[2] - 64}, 1)"

          if b.GetFixtureList().GetShape() instanceof b2CircleShape
            pos = b.GetWorldCenter()
            @s.beginPath()
            @s.arc(pos.x * 20, pos.y * 20, b.GetFixtureList().GetShape().GetRadius() * 20, 0, Math.PI*2, false)
            @s.fill()
          else
            @fillPolygon(@s, b)
      b = b.GetNext()

    # gauge
    @s.fillStyle = "rgba(255, 128, 128, 1)"
    @s.fillRect(40, 540, 400 * iris.gauge, 30)
    @s.strokeStyle = "rgba(0,0,0,1)"
    @s.strokeRect(40, 540, 400, 30)
    
    # point
    @s.fillStyle = "rgba(0,0,0,1)"
    @s.font="32px Arial"
    @s.fillText(iris.point, 440 - @s.measureText(iris.point).width, 610)

  # deprecated (don't work)
  renderdebug: (context) ->
    iris.field.world.DrawDebugData()
    # grid
    context.lineWidth = 1
    context.strokeStyle = "rgba(0,0,0,0.2);"
    @drawGrid(context)
    b = iris.field.world.GetBodyList()
    while(b)
      data = b.GetUserData()
      if data
        center = b.GetWorldCenter()
        d = "cat: " + b.GetFixtureList().GetFilterData().categoryBits.toString(16) + "\n"
        d += "mask: " + b.GetFixtureList().GetFilterData().maskBits.toString(16) + "\n"
        for k, v of data
          d += k + ": " + v + "\n"
        context.font="Arial"
        context.fillStyle = "rgba(0,0,0,1)"
        @fillTextLine(context, d, center.x * 20, center.y * 20)
      b = b.GetNext()

  fillTextLine: (context, text, x, y) ->
    list = text.split("\n")
    height = context.measureText("あ").width
    for l, i in list
      context.fillText(l, x, y+height*i)
  drawGrid: (context) ->
    for i in [0..32]
      context.beginPath()
      context.moveTo(0,20*i)
      context.lineTo(480,20*i)
      context.stroke()
    for i in [0..24]
      context.beginPath()
      context.moveTo(20*i,0)
      context.lineTo(20*i,640)
      context.stroke()

  fillPolygon: (context, body) ->
    poly = body.GetFixtureList().GetShape()
    verts = poly.GetVertices()
    context.beginPath()
    for i in [0..poly.GetVertexCount() - 1]
      v = body.GetWorldPoint(verts[i])
      if i == 0 then context.moveTo(v.x*20, v.y*20) else context.lineTo(v.x*20, v.y*20)
    context.closePath()
    context.fill()
