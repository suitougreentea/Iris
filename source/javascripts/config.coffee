b2FixtureDef = Box2D.Dynamics.b2FixtureDef
class ShapeConfig
  constructor: (@size, @density, @friction, @restitution) ->
  getFixtureDef: ->
    f = new b2FixtureDef
    f.density = @density
    f.friction = @friction
    f.restitution = @restitution
    return f

class @Config
  framerate: 30
  speedrate: 1
  gravity: 8
  shootspeedleft: 12
  shootspeedright: 24
  damagelimit: 2
  gaugefix: 0.015
  gaugepow: 1/3
  gaugeinactive: -0.07
  gaugetime: -0.0001
  fixture : {
    wall : new ShapeConfig(1, 1, 0.5, 0.5)
    floor : new ShapeConfig(1, 1, 0.5, 0.5)
    ceil : new ShapeConfig(1, 1, 0.5, 0.5)
    shoot: new ShapeConfig(0.5, 5, 0.5, 0.5)
    shape: [
      [
        new ShapeConfig(0.5, 1, 0.5, 0.5)
        new ShapeConfig(1, 1, 0.5, 0.5)
        new ShapeConfig(1.5, 1, 0.5, 0.5)
        new ShapeConfig(2, 1, 0.5, 0.5)
        new ShapeConfig(3, 1, 0.5, 0.5)
      ]
      [
        new ShapeConfig(0.5, 1, 0.5, 0.5)
        new ShapeConfig(1, 1, 0.5, 0.5)
        new ShapeConfig(1.5, 1, 0.5, 0.5)
        new ShapeConfig(2, 1, 0.5, 0.5)
        new ShapeConfig(3, 1, 0.5, 0.5)
      ]
      [
        new ShapeConfig(0.5, 1, 0.5, 0.5)
        new ShapeConfig(1, 1, 0.5, 0.5)
        new ShapeConfig(1.5, 1, 0.5, 0.5)
        new ShapeConfig(2, 1, 0.5, 0.5)
        new ShapeConfig(3, 1, 0.5, 0.5)
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
