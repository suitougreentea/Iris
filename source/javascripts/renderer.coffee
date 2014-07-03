b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
class @Renderer
  render: (context) ->
    context.clearRect(0,0,480,640)
    #context.lineWidth = 1
    #context.fillStyle = "rgba(0,0,0,0.2)"
    context.strokeStyle = "rgba(0,0,0,0.2)"
    @drawGrid(context)

    b = iris.field.world.GetBodyList()
    while(b)
      data = b.GetUserData()
      if data
        if data.type == "wall" or data.type == "floor" or data.type == "ceil"
          context.fillStyle = "rgba(128, 128, 128, 1)"
          @fillPolygon(context, b)
        if data.type == "shoot"
          context.fillStyle = "rgba(0, 0, 0, 1)"
          @fillPolygon(context, b)
        if data.type == "shape"
          color = iris.config.color[data.color]
          if data.state == iris.const.STATE_FALLING
            context.fillStyle = "rgba(#{color[0]}, #{color[1]}, #{color[2]}, 0.7)"
          else if data.state == iris.const.STATE_ACTIVE
            context.fillStyle = "rgba(#{color[0]}, #{color[1]}, #{color[2]}, 1)"
          else if data.state == iris.const.STATE_MATCH
            context.fillStyle = "rgba(#{color[0] + 64}, #{color[1] + 64}, #{color[2]}, 1)"
          else if data.state == iris.const.STATE_INACTIVE
            context.fillStyle = "rgba(#{color[0] - 64}, #{color[1] - 64}, #{color[2] - 64}, 1)"

          if b.GetFixtureList().GetShape() instanceof b2CircleShape
            pos = b.GetWorldCenter()
            context.beginPath()
            context.arc(pos.x * 20, pos.y * 20, b.GetFixtureList().GetShape().GetRadius() * 20, 0, Math.PI*2, false)
            context.fill()
          else
            @fillPolygon(context, b)
      b = b.GetNext()

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
