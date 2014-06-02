noflo = require 'noflo'
ncbi = require 'bionode-ncbi'

class XMLtoJSONProperties extends noflo.Component
  description: 'Converts specidied properties of objects from XML to JSON.'
  icons: 'files-o'
  constructor: ->
    @properties = null
    @inPorts = new noflo.InPorts
      in:
        datatype: 'object'
        description: 'Objects with properties that need conversion'
      properties:
        datatype: 'string'
        description: 'List of properties to be converted (e.g., expxml, runs)'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'string'
    @inPorts.properties.on 'data', (data) =>
      @properties = data.replace(' ', '').split(',')
    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (data) =>
      if @properties?
        ncbi.parseXMLProperties(@properties, data).on 'data', (data) =>
          @outPorts.out.send data
      else
        throw new Error 'No properties array defined for XML to JSON conversion.'
    @inPorts.in.on 'endgroup',  =>
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

exports.getComponent = -> new XMLtoJSONProperties
