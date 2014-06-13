###
Copyright (C) 2014 Markus Kohlhase <mail@markus-kohlhase.de>
###

chokidar          = require 'chokidar'
path              = require "path"
async             = require "async"
ezmlm             = require "./core"
{ EventEmitter }  = require "events"

subTypes = ['', 'mod', 'allow']

_getArrayName = (x) -> switch x
  when 'mod'    then 'moderators'
  when 'allow'  then 'aliases'
  else               'subscribers'

_getType = (x) -> switch x
  when 'mod', 'moderators' then 'mod'
  when 'allow', 'aliases'  then 'allow'
  else ''

module.exports = class List extends EventEmitter

  constructor: (cfg={}) ->
    super()
    if typeof cfg is "string"
      @name = cfg
      cfg   = { @name }
    else
      { @name } = cfg
    @dir = ezmlm._getDir cfg

    unless @name?.length > 0
      throw new Error "invalid list name"

    @[_getArrayName a] = [] for a in subTypes
    process.nextTick @_init

  _init: =>
    tasks = for t in subTypes then do (t) =>
      (next) => ezmlm.list {@name, @dir, type: t}, (err, res) =>
        @[_getArrayName t] = res unless err
        next err
    async.parallel tasks, (err) =>
      if err then @emit "error", err else @emit "ready"

  _onChange: (d) ->
    run = =>
      ezmlm.list {@name, @dir, type:d}, (err, res) =>
        type = _getArrayName d
        newAddresses = (r for r in res     when not (r in @[type]))
        delAddresses = (r for r in @[type] when not (r in res)   )
        @[type] = res
        if newAddresses.length > 0
          @emit "sub",   { addresses: newAddresses, type }
        if delAddresses.length > 0
          @emit "unsub", { addresses: delAddresses, type }
    # wait for disk writes
    setTimeout run, 500

  watch: ->
    for d in subTypes then do (d) =>
      chokidar
        .watch path.join(@dir, d, 'subscribers'),
          persistent:    yes
          ignoreInitial: yes
        .on "error", (e)  => @emit "error", e
        .on "add",        => @_onChange d
        .on "change",     => @_onChange d
        .on "unlink",     => @_onChange d

  _unSub: (addresses, type, fn) ->
    type = _getType type
    ezmlm[fn] {@name, @dir, type, addresses}, (err) =>
      @emit "error", err if err

  sub: (addresses, type) ->
    @_unSub addresses, type, "sub"

  unsub: (addresses, type) ->
    @_unSub addresses, type, "unsub"

  @_getArrayName: _getArrayName
