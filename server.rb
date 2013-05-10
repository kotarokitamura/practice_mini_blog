require 'rubygems'
require 'sinatra'
require 'haml'
require 'yaml'
require 'mysql2'
require File.dirname(__FILE__) + '/blogs_controller'
require File.dirname(__FILE__) + '/models/connect_db'
require File.dirname(__FILE__) + '/models/content'
Dir[File.dirname(__FILE__) + "/models/*.rb"].each { |file| require file }
BlogsController.run!
