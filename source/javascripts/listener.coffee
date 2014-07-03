b2ContactListener = Box2D.Dynamics.b2ContactListener
b2Body = Box2D.Dynamics.b2Body

class @IrisListener extends b2ContactListener
  BeginContact: (c) ->
    b1 = c.GetFixtureA().GetBody()
    b2 = c.GetFixtureB().GetBody()
    if c.IsTouching()
      @handleCollision(c, b1, b2)
      @handleCollision(c, b2, b1)
  EndContact: (c) ->
    b1 = c.GetFixtureA().GetBody()
    b2 = c.GetFixtureB().GetBody()
    d1 = b1.GetUserData()
    d2 = b2.GetUserData()
    #if d1 and d1.type == "shape" and b1.GetType() == b2Body.b2_staticBody
    #  b1.SetLinearVelocity(new b2Vec2(0,0))
    #  b1.SetType(b2Body.b2_dynamicBody)
    #if d2 and d2.type == "shape" and b2.GetType() == b2Body.b2_staticBody
    #  b2.SetLinearVelocity(new b2Vec2(0,0))
    #  b2.SetType(b2Body.b2_dynamicBody)

  handleCollision: (c, bm, bo) ->
    md = bm.GetUserData()
    od = bo.GetUserData()
    if md
      if md.type == "shape"
        if md.state == 0
          if (od.type != "shape" or (od.type == "shape" and ((od.state == 2 and od.color == md.color) or od.state != 2))) # TODO: when md=0 od=2 od.c!=md.c ignore collision velocity
            md.state = 1
            #bm.SetType(b2Body.b2_dynamicBody)
            filter = bm.GetFixtureList().GetFilterData()
            filter.categoryBits = iris.const.CATEGORY_SHAPE_ACTIVE
            filter.maskBits = iris.const.CATEGORY_WALL + iris.const.CATEGORY_CEIL + iris.const.CATEGORY_FLOOR + iris.const.CATEGORY_SHOOT + iris.const.CATEGORY_SHAPE_FALLING + iris.const.CATEGORY_SHAPE_ACTIVE
            bm.GetFixtureList().SetFilterData(filter)
          else
            #bm.SetLinearVelocity(new b2Vec2(2,0))
            #bm.SetAngularVelocity(0)
            bm.SetType(b2Body.b2_staticBody)
            #c.SetEnabled(false)
        if md.state == 1
          if od and od.color == md.color
            md.state = 2
        if od.type == "floor" or ((od.type == "shape" or od.type == "shoot") and od.state == 3)
          # collide with floor
          if md.state == 1 and md.corruptionTimer == -1
            md.corruptionTimer = 0
          if md.state == 2
            iris.field.destroyList.push(bm)
          if md.state != 3 and od.type == "shape" and od.state == 3 and od.color == md.color
            iris.field.destroyList.push(bm)
            iris.field.destroyList.push(bo)
      if md.type == "shoot"
        if od.type == "floor" or ((od.type == "shape" or od.type == "shoot") and od.state == 3)
          # collide with floor
          if md.state == 1 and md.corruptionTimer == -1
            md.corruptionTimer = 0
