#= require_tree .

b2World = Box2D.Dynamics.b2World
b2Vec2 = Box2D.Common.Math.b2Vec2
b2Body = Box2D.Dynamics.b2Body
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2FixtureDef = Box2D.Dynamics.b2FixtureDef
b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2DebugDraw = Box2D.Dynamics.b2DebugDraw

class shapeConfig
  constructor: (@size, @density, @friction, @restitution) ->
  getFixtureDef: ->
    f = new b2FixtureDef
    f.density = @density
    f.friction = @friction
    f.restitution = @restitution
    return f
    
this.iris = {
  const: { # TODO
    STATE_FALLING: 0
    STATE_ACTIVE: 1
    STATE_MATCH: 2
    STATE_INACTIVE: 3
    CATEGORY_WALL: 0x0001
    CATEGORY_CEIL: 0x0002
    CATEGORY_FLOOR: 0x0004
    CATEGORY_SHOOT: 0x0008
    CATEGORY_SHAPE_FALLING: 0x0010
    CATEGORY_SHAPE_ACTIVE: 0x0020
  }
  config : {
    fixture : {
      wall : new shapeConfig(1, 1, 0, 0.8)
      floor : new shapeConfig(1, 1, 0, 0.8)
      ceil : new shapeConfig(1, 1, 0, 0.8)
      shoot: new shapeConfig(0.5, 8, 0, 0.8)
      shape: [
        [
          new shapeConfig(0.5, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(2, 1, 0.5, 0.8)
          new shapeConfig(3, 1, 0.5, 0.8)
          new shapeConfig(4, 1, 0.5, 0.8)
        ]
        [
          new shapeConfig(0.5, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(2, 1, 0.5, 0.8)
          new shapeConfig(3, 1, 0.5, 0.8)
          new shapeConfig(4, 1, 0.5, 0.8)
        ]
        [
          new shapeConfig(0.5, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(2, 1, 0.5, 0.8)
          new shapeConfig(3, 1, 0.5, 0.8)
          new shapeConfig(4, 1, 0.5, 0.8)
        ]
      ]
    }
    color: [
      [255, 0, 0]
      [0, 255, 0]
      [0, 0, 255]
      [255, 255, 0]
      [255, 0, 255]
      [0, 255, 255]
    ]
  }
  field: {
    world: new b2World(new b2Vec2(0, 9.8), true)
    addShape: (type, size, angle, color, speed, position) ->
      fixtureConfig = window.iris.config.fixture
      config = fixtureConfig.shape[type][size]
      fixture = config.getFixtureDef()

      switch type
        when 0
          # box
          fixture.shape = new b2PolygonShape
          fixture.shape.SetAsBox(config.size,config.size)
        when 1
          # triangle
          v = [
            new b2Vec2(-config.size,-config.size)
            new b2Vec2( config.size, config.size)
            new b2Vec2(-config.size, config.size)
          ]
          fixture.shape = new b2PolygonShape
          fixture.shape.SetAsArray(v,3)
        when 2
          # circle
          fixture.shape = new b2CircleShape
          fixture.shape.SetRadius(config.size)
      fixture.filter.categoryBits = iris.const.CATEGORY_SHAPE_FALLING
      fixture.filter.maskBits = iris.const.CATEGORY_FLOOR + iris.const.CATEGORY_SHOOT + iris.const.CATEGORY_SHAPE_ACTIVE
      body = new b2BodyDef
      body.angle = angle
      body.type = b2Body.b2_dynamicBody
      body.userData = {type: "shape", state: 0, color: color, chain: 0} # TODO
      body.position.Set(position*20 + 2, -5) # x: 2-22
      b = @world.CreateBody(body)
      b.CreateFixture(fixture)
      b.SetLinearVelocity(new b2Vec2(0, speed)) # TODO
      b.ApplyForce(new b2Vec2(0, -9.8 * b.GetMass()), b.GetWorldCenter()) # Cancel gravity

    shoot: (x, y, vel) ->
      fixtureConfig = window.iris.config.fixture
      config = fixtureConfig.shoot
      fixture = config.getFixtureDef()
      fixture.shape = new b2PolygonShape
      fixture.shape.SetAsBox(config.size,config.size)
      fixture.filter.categoryBits = iris.const.CATEGORY_SHOOT
      fixture.filter.maskBits = iris.const.CATEGORY_WALL + iris.const.CATEGORY_CEIL + iris.const.CATEGORY_FLOOR + iris.const.CATEGORY_SHOOT + iris.const.CATEGORY_SHAPE_FALLING + iris.const.CATEGORY_SHAPE_ACTIVE
      body = new b2BodyDef
      body.type = b2Body.b2_dynamicBody
      body.userData = {type: "shoot"} # TODO
      body.position.Set(x, y)
      b = @world.CreateBody(body)
      b.CreateFixture(fixture)
      b.SetLinearVelocity(new b2Vec2(0,-vel))

    init: ->
      fixtureConfig = window.iris.config.fixture
      wallFixture = fixtureConfig.wall.getFixtureDef()
      wallFixture.shape = new b2PolygonShape
      wallFixture.shape.SetAsBox(0.5,8)
      wallFixture.filter.categoryBits = iris.const.CATEGORY_WALL
      wallBody = new b2BodyDef
      wallBody.type = b2Body.b2_staticBody
      wallBody.userData = {type: "wall"}
      wallBody.position.Set(2.5,15)
      @world.CreateBody(wallBody).CreateFixture(wallFixture)
      wallBody.position.Set(21.5,15)
      @world.CreateBody(wallBody).CreateFixture(wallFixture)
      
      floorFixture = fixtureConfig.wall.getFixtureDef()
      floorFixture.shape = new b2PolygonShape
      floorFixture.shape.SetAsBox(10,0.5)
      floorFixture.filter.categoryBits = iris.const.CATEGORY_FLOOR
      floorBody = new b2BodyDef
      floorBody.type = b2Body.b2_staticBody
      floorBody.userData = {type: "floor"}
      floorBody.position.Set(12,25.5)
      @world.CreateBody(floorBody).CreateFixture(floorFixture)

      ceilFixture = fixtureConfig.wall.getFixtureDef()
      ceilFixture.shape = new b2PolygonShape
      ceilFixture.shape.SetAsBox(10,5)
      ceilFixture.filter.categoryBits = iris.const.CATEGORY_CEIL
      ceilBody = new b2BodyDef
      ceilBody.type = b2Body.b2_staticBody
      ceilBody.userData = {type: "ceil"}
      ceilBody.position.Set(12,-4)
      @world.CreateBody(ceilBody).CreateFixture(ceilFixture)
  }

  init : ->
    console.log "Loading Iris"
    @s = document.getElementById("screen").getContext("2d")
    @ds = document.getElementById("debugscreen").getContext("2d")
    debugDraw = new b2DebugDraw
    debugDraw.SetSprite @ds
    debugDraw.SetDrawScale 20
    debugDraw.SetFillAlpha 0.7
    debugDraw.SetFlags b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit
    @field.world.SetDebugDraw debugDraw
    @field.init()
    document.getElementById("screen").onmousedown = @click
    document.getElementById("debugscreen").onmousedown = @click
    console.log "Iris ready"
    window.setInterval(update, 1000/30)

  update : ->
    @field.world.Step(1/30, 10, 10) # should be customizable
    @field.world.ClearForces()
    b = iris.field.world.GetBodyList()
    while(b)
      data = b.GetUserData()
      if data
        if data.type == "shape" and data.state == 0
          # Cancel gravity
          b.ApplyForce(new b2Vec2(0, -9.8 * b.GetMass()), b.GetWorldCenter())
      b = b.GetNext()

    c = iris.field.world.GetContactList()
    while(c)
      b1 = c.GetFixtureA().GetBody()
      b2 = c.GetFixtureB().GetBody()
      if c.IsTouching()
        @handleCollision(b1, b2)
        @handleCollision(b2, b1)
      c = c.GetNext()

    if Math.random() < 0.012
      @field.addShape(
        Math.floor(Math.random() * 2), # 3
        Math.floor(Math.random() * 4), # 5
        Math.floor(Math.random() * 360),
        Math.floor(Math.random() * 3),
        1,
        Math.random())

    @render()
    @field.world.DrawDebugData()
    # grid
    @ds.lineWidth = 1
    @ds.strokeStyle = "rgba(0,0,0,0.2);"
    @drawGrid(@ds)
    b = iris.field.world.GetBodyList()
    while(b)
      data = b.GetUserData()
      if data
        center = b.GetWorldCenter()
        d = "cat: " + b.GetFixtureList().GetFilterData().categoryBits.toString(16) + "\n"
        d += "mask: " + b.GetFixtureList().GetFilterData().maskBits.toString(16) + "\n"
        for k, v of data
          d += k + ": " + v + "\n"
        @ds.font="Arial"
        @ds.fillStyle = "rgba(0,0,0,1)"
        @fillTextLine(@ds, d, center.x * 20, center.y * 20)
      b = b.GetNext()

  render: ->
    @s.clearRect(0,0,480,640)
    #@s.lineWidth = 1
    #@s.fillStyle = "rgba(0,0,0,0.2)"
    @s.strokeStyle = "rgba(0,0,0,0.2)"
    @drawGrid(@s)

    b = iris.field.world.GetBodyList()
    while(b)
      data = b.GetUserData()
      if data
        if data.type == "wall" or data.type == "floor" or data.type == "ceil"
          @s.fillStyle = "rgba(128, 128, 128, 1)"
          @fillPolygon(b)
        if data.type == "shoot"
          @s.fillStyle = "rgba(0, 0, 0, 1)"
          @fillPolygon(b)
        if data.type == "shape"
          color = iris.config.color[data.color]
          if data.state == iris.const.STATE_FALLING
            @s.fillStyle = "rgba(#{color[0]}, #{color[1]}, #{color[2]}, 0.7)"
          else
            @s.fillStyle = "rgba(#{color[0]}, #{color[1]}, #{color[2]}, 1)"
          if b.GetFixtureList().GetShape() instanceof b2CircleShape
            pos = b.GetWorldCenter()
            @s.beginPath()
            @s.arc(pos.x * 20, pos.y * 20, b.GetFixtureList().GetShape().GetRadius() * 20, 0, Math.PI*2, false)
            @s.fill()
          else
            @fillPolygon(b)
      b = b.GetNext()

  handleCollision: (bm, bo) ->
    data = bm.GetUserData()
    if data
      if data.type == "shape" and data.state == 0
        data.state = 1
        filter = bm.GetFixtureList().GetFilterData()
        filter.categoryBits = iris.const.CATEGORY_SHAPE_ACTIVE
        filter.maskBits = iris.const.CATEGORY_WALL + iris.const.CATEGORY_CEIL + iris.const.CATEGORY_FLOOR + iris.const.CATEGORY_SHOOT + iris.const.CATEGORY_SHAPE_FALLING + iris.const.CATEGORY_SHAPE_ACTIVE
        bm.GetFixtureList().SetFilterData(filter)

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

  fillPolygon: (body) ->
    poly = body.GetFixtureList().GetShape()
    verts = poly.GetVertices()
    @s.beginPath()
    for i in [0..poly.GetVertexCount() - 1]
      v = body.GetWorldPoint(verts[i])
      if i == 0 then @s.moveTo(v.x*20, v.y*20) else @s.lineTo(v.x*20, v.y*20)
    @s.closePath()
    @s.fill()
  click: ->
    rect = event.target.getBoundingClientRect()
    iris.field.shoot((event.clientX - rect.left) / 20, (event.clientY - rect.top) / 20, 12) # should be customizable
}

window.onload = ->
  iris.init()
update = ->
  iris.update()
