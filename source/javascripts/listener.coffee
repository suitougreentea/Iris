b2ContactListener = Box2D.Dynamics.b2ContactListener
b2Body = Box2D.Dynamics.b2Body
b2Vec2 = Box2D.Common.Math.b2Vec2
b2MassData = Box2D.Dynamics.b2MassData

class @IrisListener extends b2ContactListener
  BeginContact: (c) ->
    b1 = c.GetFixtureA().GetBody()
    b2 = c.GetFixtureB().GetBody()
    if c.IsTouching()
      @handleCollision(c, b1, b2)
      @handleCollision(c, b2, b1)
  #PreSolve: (c, om) ->
  #@BeginContact c

  handleCollision: (c, bm, bo) ->
    md = bm.GetUserData()
    od = bo.GetUserData()
    if md
      if md.type == "shape"
        if md.state == 0
          if (od.type != "shape" or (od.type == "shape" and ((od.state == 2 and od.color == md.color) or od.state != 2))) # when md=0 od=2 od.c!=md.c ignore collision velocity
            md.state = 1
            bm.SetType(b2Body.b2_dynamicBody)
            filter = bm.GetFixtureList().GetFilterData()
            filter.categoryBits = iris.const.CATEGORY_SHAPE_ACTIVE
            filter.maskBits = iris.const.CATEGORY_WALL + iris.const.CATEGORY_CEIL + iris.const.CATEGORY_FLOOR + iris.const.CATEGORY_SHOOT + iris.const.CATEGORY_SHAPE_FALLING + iris.const.CATEGORY_SHAPE_ACTIVE
            bm.GetFixtureList().SetFilterData(filter)
        if md.state == 1
          if od and od.color == md.color
            if od.chainGroup == -1
              md.chainGroup = iris.chaingroups.new()
              od.chainGroup = md.chainGroup
            else
              md.chainGroup = od.chainGroup
            md.state = 2
        if od.type == "floor" or ((od.type == "shape" or od.type == "shoot") and od.state == 3)
          # collide with floor
          if md.state == 1 and md.corruptionTimer == -1
            md.corruptionTimer = 0
          if md.state == 2
            iris.chaingroups.handle(md.chainGroup, true)
            iris.field.destroyList.push(bm)
          if md.state != 3 and od.type == "shape" and od.state == 3 and od.color == md.color
            iris.chaingroups.handle(md.chainGroup, true)
            iris.field.destroyList.push(bm)
            iris.chaingroups.handle(md.chainGroup, false)
            iris.field.destroyList.push(bo)
        if md.state != 3 and od.type == "shoot"
          iris.field.destroyList.push(bo)
        if md.state == 2 and od.type == "shoot"
          md.damage++
          if md.damage == iris.config.damagelimit
            iris.field.destroyList.push(bm)
      if md.type == "shoot"
        if od.type == "floor" or ((od.type == "shape" or od.type == "shoot") and od.state == 3)
          # collide with floor
          if md.state == 1 and md.corruptionTimer == -1
            md.corruptionTimer = 0
