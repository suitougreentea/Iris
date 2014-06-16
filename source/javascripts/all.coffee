//= require_tree .

b2World = Box2D.Dynamics.b2World
b2Vec2 = Box2D.Common.Math.b2Vec2
b2Body = Box2D.Dynamics.b2Body
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2FixtureDef = Box2D.Dynamics.b2FixtureDef
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2DebugDraw = Box2D.Dynamics.b2DebugDraw

# class IrisWorld:

window.world = new b2World(new b2Vec2(0, 9.8), true)
window.onload = ->
  console.log "Loading Iris"
  console.log "Iris ready"
  canvas = document.getElementById 'screen'
  s = canvas.getContext "2d"

  fixDefault = new b2FixtureDef
  fixDefault.density = 1.0
  fixDefault.friction = 0.5
  fixDefault.restitution = 0.5
  bodyDefault = new b2BodyDef
  bodyDefault.type = b2Body.b2_dynamicBody
  fixDefault.shape = new b2PolygonShape
  fixDefault.shape.SetAsBox(1,1)
  bodyDefault.position.Set(1,1)
  world.CreateBody(bodyDefault).CreateFixture(fixDefault)
  
  debugDraw = new b2DebugDraw
  debugDraw.SetSprite s
  debugDraw.SetDrawScale 50
  debugDraw.SetFillAlpha 0.5
  debugDraw.SetFlags b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit
  world.SetDebugDraw debugDraw

  window.setInterval(update, 1000/60)

update = ->
  world.Step(1/60, 10, 10)
  world.DrawDebugData()
  world.ClearForces()
  console.log "Each frame"
