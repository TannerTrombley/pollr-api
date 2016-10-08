from flask import Flask
from flask_restful import Api
import flask_cors
from resources import Test_route

app = Flask(__name__)
flask_cors.CORS(app)
api = Api(app)

#Add resources to the api
api.add_resource(Test_route, "/test")