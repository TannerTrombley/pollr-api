from flask import Flask
from flask_restful import Api
from resources import Test_route

app = Flask(__name__)
api = Api(app)

#Add resources to the api
api.add_resource(Test_route, "/test")