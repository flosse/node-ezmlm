###
Copyright (C) 2014 Markus Kohlhase <mail@markus-kohlhase.de>
###

path     = require "path"
mkdirp   = require "mkdirp"
{ exec } = require "child_process"

checkListName = (o) ->
  if typeof(o?.name) isnt "string" or (o.name.length < 1)
    throw new Error "Invalid list name"

_getDir = (cfg) -> path.resolve cfg.dir or path.join "./", cfg.name

_getType = (cfg) -> if cfg.type then " #{cfg.type}" else ''

_exec = (cmd, cb) ->
  if typeof cb is "function" then exec cmd, cb else cmd

_unSub = (cfg, cb, t) ->
  checkListName cfg
  unless (s=cfg.addresses) instanceof Array and s.length > 0
    throw new Error "Invalid list of addresses"
  addrs = (a.trim() for a in cfg.addresses)
  _exec "ezmlm-#{t} #{_getDir cfg}#{_getType cfg} #{addrs.join(' ')}", cb

make = (cfg, cb) ->
  checkListName cfg
  if typeof(d=cfg.domain) isnt "string" or d.length < 1
    throw new Error "Invalid domain: #{d}"

  { name, domain, qmail, config, owner, from, switches, modify } = cfg

  qmail    ?= ".qmail-#{name}"
  qmail     = path.resolve qmail
  dir       = _getDir cfg

  switches  = if switches then "-#{switches} "              else ''
  config    = if config   then "-C #{path.resolve config} " else ''
  owner     = if owner    then "-5 #{owner} "               else ''
  from      = if from     then "-3 #{from} "                else ''
  modify    = if modify   then "-+ "                        else ''

  args      = "#{config}#{owner}#{from}#{switches}"

  if typeof cb is "function"
    mkdirp.sync path.resolve path.join dir, '..'

  _exec "ezmlm-make #{modify}#{args}#{dir} #{qmail} #{name} #{domain}", cb

list = (cfg, cb) ->
  checkListName cfg
  if typeof cb is "function"
    _cb = (err, res) ->
      return cb err if err
      a = res.trim().split '\n'
      a = [] if a.length is 1 and a[0] is ''
      cb null, a

  _exec "ezmlm-list #{_getDir cfg}#{_getType cfg}", _cb

sub   = (cfg, cb) -> _unSub cfg, cb, "sub"
unsub = (cfg, cb) -> _unSub cfg, cb, "unsub"

module.exports = { make, list, sub, unsub, _getDir }
