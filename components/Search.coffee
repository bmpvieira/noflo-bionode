noflo = require 'noflo'
ncbi = require 'bionode-ncbi'

class Search extends noflo.Component
  icon: 'search'
  description: 'Search NCBI databases'
  constructor: ->
    @db = null
    @inPorts = new noflo.InPorts
      in:
        datatype: 'string'
        description: 'Terms (e.g., Human, Cancer, txid9606, etc)'
      db:
        datatype: 'string'
        description: 'Database (e.g., sra, pubmed, biosample, etc)'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'string'
    @inPorts.db.on 'data', (data) =>
      @db = data
    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (data) =>
      if @db?
        ncbi.search(@db, data).on 'data', (data) =>
          @outPorts.out.send data
      else
        throw new Error 'No NCBI database defined for Search'
    @inPorts.in.on 'endgroup',  =>
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

exports.getComponent = -> new Search
