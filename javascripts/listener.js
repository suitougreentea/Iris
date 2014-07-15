(function() {
  var b2Body, b2ContactListener, b2MassData, b2Vec2,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  b2ContactListener = Box2D.Dynamics.b2ContactListener;

  b2Body = Box2D.Dynamics.b2Body;

  b2Vec2 = Box2D.Common.Math.b2Vec2;

  b2MassData = Box2D.Dynamics.b2MassData;

  this.IrisListener = (function(_super) {
    __extends(IrisListener, _super);

    function IrisListener() {
      return IrisListener.__super__.constructor.apply(this, arguments);
    }

    IrisListener.prototype.BeginContact = function(c) {
      var b1, b2;
      b1 = c.GetFixtureA().GetBody();
      b2 = c.GetFixtureB().GetBody();
      if (c.IsTouching()) {
        this.handleCollision(c, b1, b2);
        return this.handleCollision(c, b2, b1);
      }
    };

    IrisListener.prototype.handleCollision = function(c, bm, bo) {
      var filter, md, od;
      md = bm.GetUserData();
      od = bo.GetUserData();
      if (md) {
        if (md.type === "shape") {
          if (md.state === 0) {
            if (od.type !== "shape" || (od.type === "shape" && ((od.state === 2 && od.color === md.color) || od.state !== 2))) {
              md.state = 1;
              bm.SetType(b2Body.b2_dynamicBody);
              filter = bm.GetFixtureList().GetFilterData();
              filter.categoryBits = iris["const"].CATEGORY_SHAPE_ACTIVE;
              filter.maskBits = iris["const"].CATEGORY_WALL + iris["const"].CATEGORY_CEIL + iris["const"].CATEGORY_FLOOR + iris["const"].CATEGORY_SHOOT + iris["const"].CATEGORY_SHAPE_FALLING + iris["const"].CATEGORY_SHAPE_ACTIVE;
              bm.GetFixtureList().SetFilterData(filter);
            }
          }
          if (md.state === 1) {
            if (od && od.color === md.color) {
              if (od.chainGroup === -1) {
                md.chainGroup = iris.chaingroups["new"]();
                od.chainGroup = md.chainGroup;
              } else {
                md.chainGroup = od.chainGroup;
              }
              md.state = 2;
            }
          }
          if (od.type === "floor" || ((od.type === "shape" || od.type === "shoot") && od.state === 3)) {
            if (md.state === 1 && md.corruptionTimer === -1) {
              md.corruptionTimer = 0;
            }
            if (md.state === 2) {
              iris.chaingroups.handle(md.chainGroup, true);
              iris.field.destroyList.push(bm);
            }
            if (md.state !== 3 && od.type === "shape" && od.state === 3 && od.color === md.color) {
              iris.chaingroups.handle(md.chainGroup, true);
              iris.field.destroyList.push(bm);
              iris.chaingroups.handle(md.chainGroup, false);
              iris.field.destroyList.push(bo);
            }
          }
          if (md.state !== 3 && od.type === "shoot") {
            iris.field.destroyList.push(bo);
          }
          if (md.state === 2 && od.type === "shoot") {
            md.damage++;
            if (md.damage === iris.config.damagelimit) {
              iris.field.destroyList.push(bm);
            }
          }
        }
        if (md.type === "shoot") {
          if (od.type === "floor" || ((od.type === "shape" || od.type === "shoot") && od.state === 3)) {
            if (md.state === 1 && md.corruptionTimer === -1) {
              return md.corruptionTimer = 0;
            }
          }
        }
      }
    };

    return IrisListener;

  })(b2ContactListener);

}).call(this);
