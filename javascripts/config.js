(function() {
  var ShapeConfig, b2FixtureDef;

  b2FixtureDef = Box2D.Dynamics.b2FixtureDef;

  ShapeConfig = (function() {
    function ShapeConfig(size, density, friction, restitution) {
      this.size = size;
      this.density = density;
      this.friction = friction;
      this.restitution = restitution;
    }

    ShapeConfig.prototype.getFixtureDef = function() {
      var f;
      f = new b2FixtureDef;
      f.density = this.density;
      f.friction = this.friction;
      f.restitution = this.restitution;
      return f;
    };

    return ShapeConfig;

  })();

  this.Config = (function() {
    function Config() {}

    Config.prototype.framerate = 30;

    Config.prototype.speedrate = 1;

    Config.prototype.gravity = 8;

    Config.prototype.shootspeedleft = 12;

    Config.prototype.shootspeedright = 24;

    Config.prototype.damagelimit = 2;

    Config.prototype.gaugefix = 0.015;

    Config.prototype.gaugepow = 1 / 3;

    Config.prototype.gaugeinactive = -0.07;

    Config.prototype.gaugetime = -0.0001;

    Config.prototype.fixture = {
      wall: new ShapeConfig(1, 1, 0.5, 0.5),
      floor: new ShapeConfig(1, 1, 0.5, 0.5),
      ceil: new ShapeConfig(1, 1, 0.5, 0.5),
      shoot: new ShapeConfig(0.5, 5, 0.5, 0.5),
      shape: [[new ShapeConfig(0.5, 1, 0.5, 0.5), new ShapeConfig(1, 1, 0.5, 0.5), new ShapeConfig(1.5, 1, 0.5, 0.5), new ShapeConfig(2, 1, 0.5, 0.5), new ShapeConfig(3, 1, 0.5, 0.5)], [new ShapeConfig(0.5, 1, 0.5, 0.5), new ShapeConfig(1, 1, 0.5, 0.5), new ShapeConfig(1.5, 1, 0.5, 0.5), new ShapeConfig(2, 1, 0.5, 0.5), new ShapeConfig(3, 1, 0.5, 0.5)], [new ShapeConfig(0.5, 1, 0.5, 0.5), new ShapeConfig(1, 1, 0.5, 0.5), new ShapeConfig(1.5, 1, 0.5, 0.5), new ShapeConfig(2, 1, 0.5, 0.5), new ShapeConfig(3, 1, 0.5, 0.5)]]
    };

    Config.prototype.color = [[255, 0, 0], [0, 255, 0], [0, 0, 255], [255, 255, 0], [255, 0, 255], [0, 255, 255]];

    return Config;

  })();

}).call(this);
