#= require_tree .

b2World = Box2D.Dynamics.b2World
b2Vec2 = Box2D.Common.Math.b2Vec2
b2Body = Box2D.Dynamics.b2Body
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2FixtureDef = Box2D.Dynamics.b2FixtureDef
b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2DebugDraw = Box2D.Dynamics.b2DebugDraw
    
this.iris = {
  const: { # TODO
    STATE_FALLING: 0
    STATE_ACTIVE: 1
    STATE_MATCH: 2
    STATE_INACTIVE: 3
    SHAPE_BOX: 0
    SHAPE_TRIANGLE:1
    SHAPE_CIRCLE: 2
    CATEGORY_WALL: 0x0001
    CATEGORY_CEIL: 0x0002
    CATEGORY_FLOOR: 0x0004
    CATEGORY_SHOOT: 0x0008
    CATEGORY_SHAPE_FALLING: 0x0010
    CATEGORY_SHAPE_ACTIVE: 0x0020
  }
  config : new Config()
  field: {
    world: new b2World(new b2Vec2(0, 9.8), true)
    destroyList: []
    addShape: (type, size, angle, color, speed, position) ->
      fixtureConfig = window.iris.config.fixture
      config = fixtureConfig.shape[type][size]
      fixture = config.getFixtureDef()

      switch type
        when iris.const.SHAPE_BOX
          fixture.shape = new b2PolygonShape
          fixture.shape.SetAsBox(config.size,config.size)
        when iris.const.SHAPE_TRIANGLE
          v = [
            new b2Vec2(-config.size,-config.size)
            new b2Vec2( config.size, config.size)
            new b2Vec2(-config.size, config.size)
          ]
          fixture.shape = new b2PolygonShape
          fixture.shape.SetAsArray(v,3)
        when iris.const.SHAPE_CIRCLE
          fixture.shape = new b2CircleShape
          fixture.shape.SetRadius(config.size)
      fixture.filter.categoryBits = iris.const.CATEGORY_SHAPE_FALLING
      fixture.filter.maskBits = iris.const.CATEGORY_FLOOR + iris.const.CATEGORY_SHOOT + iris.const.CATEGORY_SHAPE_ACTIVE
      body = new b2BodyDef
      body.angle = angle
      body.type = b2Body.b2_dynamicBody
      #body.type = b2Body.b2_kinematicBody
      body.userData = {type: "shape", state: 0, color: color, chainGroup: -1, corruptionTimer: -1} # TODO
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
      body.userData = {type: "shoot", state: iris.const.STATE_ACTIVE, corruptionTimer: -1, destroyTimer: 0} # TODO
      body.position.Set(x, y)
      b = @world.CreateBody(body)
      b.CreateFixture(fixture)
      b.SetLinearVelocity(new b2Vec2(0,-vel))

    init: ->
      new FieldNormal().generate(@world)
      @world.SetContactListener iris.listener
  }
  gauge: 1
  chaingroups: {
    groups: []
    new: ->
      len = @groups.length
      @groups[len] = 0
      return len
    handle: (group) ->
      ## TODO: add point ##
      @groups[group]++
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
    window.setInterval(update, 1000 / iris.config.framerate)

  listener: new IrisListener()
  renderer: new Renderer()

  update : ->
    @field.world.Step(1 / (iris.config.framerate / iris.config.speedrate) , 10, 10) # should be customizable
    @field.world.ClearForces()
    b = iris.field.world.GetBodyList()
    while(b)
      data = b.GetUserData()
      if data
        if data.type == "shape"
          #b.SetType(b2Body.b2_dynamicBody)
          if data.state == 0
            # Cancel gravity
            b.ApplyForce(new b2Vec2(0, -9.8 * b.GetMass()), b.GetWorldCenter())
            #b.SetLinearVelocity(new b2Vec2(0,5))
            #b.SetAngularVelocity(0)
          if data.corruptionTimer > -1
            data.corruptionTimer++
            if data.corruptionTimer > 30 # TODO
              data.state = iris.const.STATE_INACTIVE
        if data.type == "shoot"
          if data.corruptionTimer > -1
            data.corruptionTimer++
            if data.corruptionTimer > 30 # TODO
              data.state = iris.const.STATE_INACTIVE
          data.destroyTimer++
          if data.destroyTimer > 300 # TODO
            iris.field.destroyList.push(b)
          
        if b.GetWorldCenter().y > 50
          iris.field.destroyList.push(b)
      b = b.GetNext()

    if Math.random() < 0.1
      @field.addShape(
        Math.floor(Math.random() * 3), # Type (3)
        Math.floor(Math.random() * 5), # Size (5)
        Math.floor(Math.random() * 360), # Angle
        Math.floor(Math.random() * 1), # Color
        Math.random() + 1, # Speed
        Math.random()) # Pos

    @gauge -= 0.0001

    for body in iris.field.destroyList
      iris.field.world.DestroyBody(body)
    iris.field.destroyList = []

    @renderer.render(@s)
    @renderer.renderdebug(@ds)

  click: ->
    rect = event.target.getBoundingClientRect()
    iris.field.shoot((event.clientX - rect.left) / 20, (event.clientY - rect.top) / 20, 12) # should be customizable
}

window.onload = ->
  iris.init()
update = ->
  iris.update()
