chai = require "chai"
chai.should()
path = require "path"

describe "The ezmlm module", ->

  ezmlm = require "../src/ezmlm"

  it "provides a make method", ->
    ezmlm.make.should.be.a "function"

  it "provides a list method", ->
    ezmlm.list.should.be.a "function"

  it "provides a sub method", ->
    ezmlm.sub.should.be.a "function"

  it "provides a unsub method", ->
    ezmlm.unsub.should.be.a "function"

  it "provides a _getDir helper method", ->
    ezmlm._getDir.should.be.a "function"
    ezmlm._getDir({name: "bla"}).should.equal path.resolve './bla'
    ezmlm._getDir({name: "bla", dir:"blub"}).should.equal path.resolve './blub'

  it "checks for a correct cfg object", ->
    (-> ezmlm.make()                                  ).should.Throw()
    (-> ezmlm.make  {}                                ).should.Throw()
    (-> ezmlm.make  {name: 5}                         ).should.Throw()
    (-> ezmlm.make  {name: "fo", domain: 7}           ).should.Throw()
    (-> ezmlm.make  {name: "fo", domain: "bar"}       ).should.not.Throw()
    (-> ezmlm.list  {name: "fo" }                     ).should.not.Throw()
    (-> ezmlm.sub   {name: "fo" }                     ).should.Throw()
    (-> ezmlm.sub   {name: "fo", addresses: [] }      ).should.Throw()
    (-> ezmlm.sub   {name: "fo", addresses: ["foo"]}  ).should.not.Throw()
    (-> ezmlm.sub   {}                                ).should.Throw()
    (-> ezmlm.unsub {name: "fo" }                     ).should.Throw()
    (-> ezmlm.unsub {name: "fo", addresses: ["foo"]}  ).should.not.Throw()

  describe "make command", ->

    it "create a new list depending on the configuration", ->
      cfg  = { name: "foo", domain: "bar" }

      dirPath   = path.resolve "./foo"
      qmailPath = path.resolve "./.qmail-foo"

      result = "ezmlm-make #{dirPath} #{qmailPath} foo bar"
      ezmlm.make(cfg).should.equal result

      cfg.config = "/etc/ezmlm/de"
      result = "ezmlm-make -C /etc/ezmlm/de #{dirPath} #{qmailPath} foo bar"
      ezmlm.make(cfg).should.equal result

      cfg.config = ''
      cfg.owner = "owner@example"
      result = "ezmlm-make -5 owner@example #{dirPath} #{qmailPath} foo bar"
      ezmlm.make(cfg).should.equal result

      cfg.from = 'from@address'
      result = "ezmlm-make -5 owner@example -3 from@address #{dirPath} #{qmailPath} foo bar"
      ezmlm.make(cfg).should.equal result

      cfg.switches = 'aBcDeFg'
      result = "ezmlm-make -5 owner@example -3 from@address -aBcDeFg #{dirPath} #{qmailPath} foo bar"
      ezmlm.make(cfg).should.equal result

    it "respects the dir and qmail properties", ->

      cfg =
        name  : "foo"
        domain: "bar"
        dir   : './blub/blabla'
        qmail : 'myQmailFilePrefix'

      dirPath   = path.resolve "blub/blabla"
      qmailPath = path.resolve "./myQmailFilePrefix"
      result    = "ezmlm-make #{dirPath} #{qmailPath} foo bar"
      ezmlm.make(cfg).should.equal result

  describe "list command", ->

    it "returns an array with the current subscribers", ->
      cfg  = { name: "list" }
      dirPath   = path.resolve "./list"
      result = "ezmlm-list #{dirPath}"
      ezmlm.list(cfg).should.equal result

      cfg.type = "mod"
      result = "ezmlm-list #{dirPath} mod"
      ezmlm.list(cfg).should.equal result

  describe "sub command", ->

    it "subscribes an array of subscribers", ->
      cfg  = { name: "list" }
      dirPath   = path.resolve "./list"
      (-> ezmlm.sub(cfg)).should.Throw()

      result = "ezmlm-sub #{dirPath} foo@bar"
      cfg.addresses = ["foo@bar"]
      ezmlm.sub(cfg).should.equal result

      cfg.type = "mod"
      cfg.addresses = ["foo@bar", "baz@domain"]
      result = "ezmlm-sub #{dirPath} mod foo@bar baz@domain"
      ezmlm.sub(cfg).should.equal result

  describe "unsub command", ->

    it "unsubscribes an array of addresses", ->
      cfg  = { name: "list" }
      dirPath   = path.resolve "./list"
      (-> ezmlm.unsub(cfg)).should.Throw()

      result = "ezmlm-unsub #{dirPath} foo@bar"
      cfg.addresses = ["foo@bar"]
      ezmlm.unsub(cfg).should.equal result

      cfg.type = "mod"
      cfg.addresses = ["foo@bar", "baz@domain"]
      result = "ezmlm-unsub #{dirPath} mod foo@bar baz@domain"
      ezmlm.unsub(cfg).should.equal result
