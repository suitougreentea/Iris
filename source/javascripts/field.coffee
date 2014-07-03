b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2Body = Box2D.Dynamics.b2Body

class @FieldNormal
  generate: (world) ->
      fixtureConfig = window.iris.config.fixture
      wallFixture = fixtureConfig.wall.getFixtureDef()
      wallFixture.shape = new b2PolygonShape
      wallFixture.shape.SetAsBox(0.5,8)
      wallFixture.filter.categoryBits = iris.const.CATEGORY_WALL
      wallBody = new b2BodyDef
      wallBody.type = b2Body.b2_staticBody
      wallBody.userData = {type: "wall"}
      wallBody.position.Set(2.5,15)
      world.CreateBody(wallBody).CreateFixture(wallFixture)
      wallBody.position.Set(21.5,15)
      world.CreateBody(wallBody).CreateFixture(wallFixture)
      
      floorFixture = fixtureConfig.wall.getFixtureDef()
      floorFixture.shape = new b2PolygonShape
      floorFixture.shape.SetAsBox(10,0.5)
      floorFixture.filter.categoryBits = iris.const.CATEGORY_FLOOR
      floorBody = new b2BodyDef
      floorBody.type = b2Body.b2_staticBody
      floorBody.userData = {type: "floor"}
      floorBody.position.Set(12,25.5)
      world.CreateBody(floorBody).CreateFixture(floorFixture)

      ceilFixture = fixtureConfig.wall.getFixtureDef()
      ceilFixture.shape = new b2PolygonShape
      ceilFixture.shape.SetAsBox(10,5)
      ceilFixture.filter.categoryBits = iris.const.CATEGORY_CEIL
      ceilBody = new b2BodyDef
      ceilBody.type = b2Body.b2_staticBody
      ceilBody.userData = {type: "ceil"}
      ceilBody.position.Set(12,-4)
      world.CreateBody(ceilBody).CreateFixture(ceilFixture)
