from google.appengine.ext import ndb

# this file controls the model of the points object

class Points(ndb.Model):
    # the user_id is the entity id value as well.
    count = ndb.IntegerProperty(default=0)

    def update_points(self, i=1):
        self.count += i
        self.put()



def get_or_create_points(user_id):
    p = Points.get_by_id(user_id)
    if not p:
        p = Points(id=user_id)
    p.put()
    return p