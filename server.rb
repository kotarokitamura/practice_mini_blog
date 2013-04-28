require 'rubygems'
require 'sinatra'
require 'haml'
require 'yaml'
require 'mysql2'
require File.dirname(__FILE__) + '/blogs_controller'
Dir[File.dirname(__FILE__) + "/models/*.rb"].each { |file| require file }
BlogsController.run!
