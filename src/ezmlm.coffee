###
Copyright (C) 2014 Markus Kohlhase <mail@markus-kohlhase.de>
###

path     = require "path"
{ exec } = require "child_process"

checkListName = (o) ->
  if typeof(o?.name) isnt "string" or (o.name.length < 1)
    throw new Error "Invalid list name"

getDir = (cfg) ->
  dir =  cfg.dir or "./ezmlm"
  path.resolve path.join dir, cfg.name

getType = (cfg) -> if cfg.type then " #{cfg.type}" else ''

_exec = (cmd, cb) ->
  if typeof cb is "function" then exec cmd, cb else cmd

_unSub = (cfg, cb, t) ->
  checkListName cfg
  unless (s=cfg.addresses) instanceof Array and s.length > 0
    throw new Error "Invalid list of addresses"
  _exec "ezmlm-#{t} #{getDir cfg}#{getType cfg} #{cfg.addresses.join(' ')}"

make = (cfg, cb) ->
  checkListName cfg
  if typeof(d=cfg.domain) isnt "string" or d.length < 1
    throw new Error "Invalid domain: #{d}"

  { name, domain, qmail, config, owner, from, switches } = cfg

  qmail    ?= ".qmail-#{name}"
  qmail     = path.resolve qmail
  dir       = getDir cfg

  switches  = if switches then "-#{switches} "              else ''
  config    = if config   then "-C #{path.resolve config} " else ''
  owner     = if owner    then "-5 #{owner} "               else ''
  from      = if from     then "-3 #{from} "                else ''

  args      = "#{config}#{owner}#{from}#{switches}"

  _exec "ezmlm-make #{args}#{dir} #{qmail} #{name} #{domain}"


list = (cfg, cb) ->
  checkListName cfg
  _exec "ezmlm-list #{getDir cfg}#{getType cfg}"

sub   = (cfg, cb) -> _unSub cfg, cb, "sub"
unsub = (cfg, cb) -> _unSub cfg, cb, "unsub"

module.exports = { make, list, sub, unsub }
