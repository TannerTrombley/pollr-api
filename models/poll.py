from google.appengine.ext import ndb, search
import logging
from flask import request


# The following class is needed if we want to return a json representation of the poll
class DateTimeProperty(ndb.DateTimeProperty):
    '''
    Override the ndb datetimeproperty in order to allow it to be serialized to json
    '''

    # Override to allow JSON serialization
    def _get_for_dict(self, entity):
        value = super(DateTimeProperty, self)._get_for_dict(entity)
        return value.isoformat()


class Answer(ndb.Model):
    '''
    This is a structured representation of an answer option to a poll
    '''
    count = ndb.IntegerProperty(required=True, default=0)
    answer_text = ndb.StringProperty(required=True)




class Poll(ndb.Model):
    '''
    This is the datastore representation of a poll.
    '''

    # Meta Data
    created_by = ndb.StringProperty(required=True)
    created_date = DateTimeProperty(auto_now_add=True)
    last_edited = DateTimeProperty(auto_now=True)
    participants = ndb.StringProperty(repeated=True)


    # Actual Poll information
    question = ndb.TextProperty(required=True)
    answers = ndb.StructuredProperty(Answer, repeated=True)
    # location = ndb.GeoPtProperty(required=True)
    lat = ndb.FloatProperty(required=True)
    lon = ndb.FloatProperty(required=True)
    radius = ndb.IntegerProperty(required=True)

    def serialize(self):
        # print("date", self.created_date)
        # print("loc", self.location.__dict__)
        d = self.to_dict()
        d['id'] = self._entity_key.id()
        # d['id'] = id
        # d['location'] = {
        #     "lat": self.location.__dict__['lat'],
        #     "lon": self.location.__dict__['lon']
        # }
        # print d
        return d




