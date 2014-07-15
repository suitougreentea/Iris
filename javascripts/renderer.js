(function() {
  var b2CircleShape;

  b2CircleShape = Box2D.Collision.Shapes.b2CircleShape;

  this.Renderer = (function() {
    function Renderer() {}

    Renderer.prototype.init = function() {
      this.s = document.getElementById("screen").getContext("2d");
      this.setclip();
      return this.s.save();
    };

    Renderer.prototype.setclip = function() {
      this.s.beginPath();
      this.s.moveTo(0, 0);
      this.s.lineTo(480, 0);
      this.s.lineTo(480, 640);
      this.s.lineTo(0, 640);
      return this.s.clip();
    };

    Renderer.prototype.resize = function(size) {
      var result;
      result = {};
      if (size.width / size.height < 480 / 640) {
        result.x = 0;
        result.y = (size.height - ((size.width / 480) * 640)) / 2;
        result.zoom = size.width / 480;
      } else {
        result.x = (size.width - ((size.height / 640) * 480)) / 2;
        result.y = 0;
        result.zoom = size.height / 640;
      }
      this.s.restore();
      this.s.translate(result.x, result.y);
      this.s.scale(result.zoom, result.zoom);
      this.setclip();
      this.s.save();
      return result;
    };

    Renderer.prototype.render = function() {
      var b, color, data, pos;
      this.s.clearRect(0, 0, 480, 640);
      this.s.strokeStyle = "rgba(0,0,0,0.2)";
      this.drawGrid(this.s);
      this.s.strokeStyle = "rgba(0, 0, 0, 1)";
      this.s.strokeRect(0, 0, 480, 640);
      b = iris.field.world.GetBodyList();
      while (b) {
        data = b.GetUserData();
        if (data) {
          if (data.type === "wall" || data.type === "floor" || data.type === "ceil") {
            this.s.fillStyle = "rgba(128, 128, 128, 1)";
            this.fillPolygon(this.s, b);
          }
          if (data.type === "shoot") {
            this.s.fillStyle = "rgba(0, 0, 0, 1)";
            this.fillPolygon(this.s, b);
          }
          if (data.type === "shape") {
            color = iris.config.color[data.color];
            if (data.state === iris["const"].STATE_FALLING) {
              this.s.fillStyle = "rgba(" + color[0] + ", " + color[1] + ", " + color[2] + ", 0.7)";
            } else if (data.state === iris["const"].STATE_ACTIVE) {
              this.s.fillStyle = "rgba(" + color[0] + ", " + color[1] + ", " + color[2] + ", 1)";
            } else if (data.state === iris["const"].STATE_MATCH) {
              this.s.fillStyle = "rgba(" + (color[0] + 64) + ", " + (color[1] + 64) + ", " + color[2] + ", 1)";
            } else if (data.state === iris["const"].STATE_INACTIVE) {
              this.s.fillStyle = "rgba(" + (color[0] - 64) + ", " + (color[1] - 64) + ", " + (color[2] - 64) + ", 1)";
            }
            if (b.GetFixtureList().GetShape() instanceof b2CircleShape) {
              pos = b.GetWorldCenter();
              this.s.beginPath();
              this.s.arc(pos.x * 20, pos.y * 20, b.GetFixtureList().GetShape().GetRadius() * 20, 0, Math.PI * 2, false);
              this.s.fill();
            } else {
              this.fillPolygon(this.s, b);
            }
          }
        }
        b = b.GetNext();
      }
      this.s.fillStyle = "rgba(255, 128, 128, 1)";
      this.s.fillRect(40, 540, 400 * iris.gauge, 30);
      this.s.strokeStyle = "rgba(0,0,0,1)";
      this.s.strokeRect(40, 540, 400, 30);
      this.s.fillStyle = "rgba(0,0,0,1)";
      this.s.font = "32px IrisNum, sans-serif";
      return this.s.fillText(iris.point, 440 - this.s.measureText(iris.point).width, 610);
    };

    Renderer.prototype.renderdebug = function(context) {
      var b, center, d, data, k, v, _results;
      iris.field.world.DrawDebugData();
      context.lineWidth = 1;
      context.strokeStyle = "rgba(0,0,0,0.2);";
      this.drawGrid(context);
      b = iris.field.world.GetBodyList();
      _results = [];
      while (b) {
        data = b.GetUserData();
        if (data) {
          center = b.GetWorldCenter();
          d = "cat: " + b.GetFixtureList().GetFilterData().categoryBits.toString(16) + "\n";
          d += "mask: " + b.GetFixtureList().GetFilterData().maskBits.toString(16) + "\n";
          for (k in data) {
            v = data[k];
            d += k + ": " + v + "\n";
          }
          context.font = "Arial";
          context.fillStyle = "rgba(0,0,0,1)";
          this.fillTextLine(context, d, center.x * 20, center.y * 20);
        }
        _results.push(b = b.GetNext());
      }
      return _results;
    };

    Renderer.prototype.fillTextLine = function(context, text, x, y) {
      var height, i, l, list, _i, _len, _results;
      list = text.split("\n");
      height = context.measureText("あ").width;
      _results = [];
      for (i = _i = 0, _len = list.length; _i < _len; i = ++_i) {
        l = list[i];
        _results.push(context.fillText(l, x, y + height * i));
      }
      return _results;
    };

    Renderer.prototype.drawGrid = function(context) {
      var i, _i, _j, _results;
      for (i = _i = 0; _i <= 32; i = ++_i) {
        context.beginPath();
        context.moveTo(0, 20 * i);
        context.lineTo(480, 20 * i);
        context.stroke();
      }
      _results = [];
      for (i = _j = 0; _j <= 24; i = ++_j) {
        context.beginPath();
        context.moveTo(20 * i, 0);
        context.lineTo(20 * i, 640);
        _results.push(context.stroke());
      }
      return _results;
    };

    Renderer.prototype.fillPolygon = function(context, body) {
      var i, poly, v, verts, _i, _ref;
      poly = body.GetFixtureList().GetShape();
      verts = poly.GetVertices();
      context.beginPath();
      for (i = _i = 0, _ref = poly.GetVertexCount() - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        v = body.GetWorldPoint(verts[i]);
        if (i === 0) {
          context.moveTo(v.x * 20, v.y * 20);
        } else {
          context.lineTo(v.x * 20, v.y * 20);
        }
      }
      context.closePath();
      return context.fill();
    };

    return Renderer;

  })();

}).call(this);
