
class window.FlightFactory
  instance = null

  class FlightListParser
    flightList = new Array()

    constructor: (@url) ->
      @createFlightList()

    createFlightList: ->
      jQuery.ajax
        url: @url,
        dataType: 'jsonp',
        jsonp: 'jsonp',
        jsonpCallback: 'jsonCallback'

        error: (a, b, e) ->
          alert e;
          console.log(e);

        success: (data) ->
          for f in data['flights']['flight']
            tmpFlight = new Flight(f)
            flightList.push(tmpFlight)

          onFlightLoadComplete(flightList)

    getFlight: (flightId) ->
      tmpLst = new Array()

      for i in [0...flightList.length]
        if (flightList[i].flightId.toUpperCase() is flightId.toUpperCase())
          tmpLst.push(flightList[i])

      return tmpLst

  @getInstance: (url) ->
    instance ?= new FlightListParser(url)

###
val = new UrlBuilder('http://flydata.avinor.no/XmlFeed.asp?', "OSL").timeFrom(2).timeTo(4).direction("a").buildUrl()
console.log(val)

###
