chai = require "chai"
path = require "path"
chai.should()

describe "The ezmlm List class", ->

  List = require "../src/List"

  # our test environment might not provide ezmlm
  # therefore we have to replace the init method
  List::_init = ->

  { EventEmitter } = require "events"

  it "is a class", ->
    List.should.be.a "function"

  it "has a name property", ->
    (-> new List()).should.Throw()
    (-> new List "foo").should.not.Throw()
    (new List "bar").name.should.equal "bar"
  it "has a dir property", ->
    (new List "bar").dir.should.equal path.resolve "./bar/"

  it "has a subscribers property", ->
    (new List "bar").subscribers.should.be.an "array"

  it "has a moderators property", ->
    (new List "bar").moderators.should.be.an "array"

  it "has a aliases property", ->
    (new List "bar").aliases.should.be.an "array"

  it "is a EventEmitter", ->
    (new List("x") instanceof EventEmitter).should.equal true

  it "has a watch method", ->
    (new List "bar").watch.should.be.a "function"

  it "has a sub method", ->
    (new List "bar").sub.should.be.a "function"

  it "has a unsub method", ->
    (new List "bar").unsub.should.be.a "function"

  it "has a _getArrayName helper method", ->
    fn = List._getArrayName
    fn('').should.equal 'subscribers'
    fn('foo').should.equal 'subscribers'
    fn('mod').should.equal 'moderators'
    fn('allow').should.equal 'aliases'
