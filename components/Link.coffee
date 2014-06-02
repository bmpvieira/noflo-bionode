noflo = require 'noflo'
ncbi = require 'bionode-ncbi'

class Link extends noflo.Component
  description: 'Does NCBI link, i.e., searches a database for unique IDs related to an ID from another database.'
  icon: 'link'
  constructor: ->
    @dbs = null
    @inPorts = new noflo.InPorts
      in:
        datatype: 'string'
        description: 'Unique IDs to be linked to IDs of another database'
      dbs:
        datatype: 'string'
        description: 'Source and destination databases (e.g., sra, pubmed)'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'string'
    @inPorts.dbs.on 'data', (data) =>
      @dbs = data.replace(' ', '').split(',')
    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (data) =>
      if @dbs
        ncbi.link(@dbs[0], @dbs[1], data).on 'data', (data) =>
          @outPorts.out.send data
      else
        throw new Error 'NCBI databases to be linked not defined'
    @inPorts.in.on 'endgroup',  =>
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

exports.getComponent = -> new Link
