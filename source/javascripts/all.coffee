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
  config : {
    fixture : {
      wall : new shapeConfig(1, 1, 0, 0.8)
      floor : new shapeConfig(1, 1, 0, 0.8)
      ceil : new shapeConfig(1, 1, 0, 0.8)
      shoot: new shapeConfig(0.5, 1, 0, 0.8)
      shape: [
        [
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
        ]
        [
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
        ]
        [
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
          new shapeConfig(1, 1, 0.5, 0.8)
        ]
      ]
    }
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
      
      body = new b2BodyDef
      body.angle = angle
      body.type = b2Body.b2_kinematicBody
      body.userData = {type: "shape", data: undefined} # TODO
      body.position.Set(position*20 + 2, 5) # x: 2-22
      @world.CreateBody(body).CreateFixture(fixture)
    shoot: (x, y, vel) ->
      fixtureConfig = window.iris.config.fixture
      config = fixtureConfig.shoot
      fixture = config.getFixtureDef()

      fixture.shape = new b2PolygonShape
      fixture.shape.SetAsBox(config.size,config.size)
      
      body = new b2BodyDef
      body.type = b2Body.b2_dynamicBody
      body.userData = {type: "shoot", data: undefined} # TODO
      body.position.Set(x, y)
      b = @world.CreateBody(body)
      b.CreateFixture(fixture)
      b.SetLinearVelocity(new b2Vec2(0,-vel))

    init: ->
      fixtureConfig = window.iris.config.fixture
      wallFixture = fixtureConfig.wall.getFixtureDef()
      wallFixture.shape = new b2PolygonShape
      wallFixture.shape.SetAsBox(0.5,8)
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
      floorBody = new b2BodyDef
      floorBody.type = b2Body.b2_staticBody
      floorBody.userData = {type: "floor"}
      floorBody.position.Set(12,25.5)
      @world.CreateBody(floorBody).CreateFixture(floorFixture)

      ceilFixture = fixtureConfig.wall.getFixtureDef()
      ceilFixture.shape = new b2PolygonShape
      ceilFixture.shape.SetAsBox(10,5)
      ceilBody = new b2BodyDef
      ceilBody.type = b2Body.b2_staticBody
      ceilBody.userData = {type: "ceil"}
      ceilBody.position.Set(12,-4)
      @world.CreateBody(ceilBody).CreateFixture(ceilFixture)
      
      @addShape(0,0,0,0,0,0.4)
      @addShape(1,0,0,0,0,0.5)
      @addShape(2,0,0,0,0,0.6)
  }

  init : ->
    console.log "Loading Iris"
    @s = document.getElementById("screen").getContext("2d")
    debugDraw = new b2DebugDraw
    debugDraw.SetSprite @s
    debugDraw.SetDrawScale 20
    debugDraw.SetFillAlpha 0.7
    debugDraw.SetFlags b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit
    @field.world.SetDebugDraw debugDraw
    @field.init()
    document.getElementById("screen").onmousedown = @click
    console.log "Iris ready"
    window.setInterval(update, 1000/30)

  update : ->
    @field.world.Step(1/30, 10, 10) # should be customizable
    b = iris.field.world.GetBodyList()
    while(b)
      if b.GetType() == 1
        pos = b.GetPosition()
        b.SetPosition(new b2Vec2(pos.x, pos.y + 0.01)) # should be customizable
      b = b.GetNext()

    @field.world.DrawDebugData()
    # grid
    @s.lineWidth = 1
    @s.strokeStyle = "rgba(0,0,0,0.2);"
    for i in [0..32]
      @s.beginPath()
      @s.moveTo(0,20*i)
      @s.lineTo(480,20*i)
      @s.stroke()
    for i in [0..24]
      @s.beginPath()
      @s.moveTo(20*i,0)
      @s.lineTo(20*i,640)
      @s.stroke()
    @field.world.ClearForces()

  click: ->
    iris.field.shoot(event.clientX / 20, event.clientY / 20, 12) # should be customizable
}

window.onload = ->
  iris.init()
update = ->
  iris.update()
