###
flightUrl = new UrlBuilder('http://freberg.org/xmlproxy.php?url=', 'http://flydata.avinor.no/XmlFeed.asp?', 'OSL').timeFrom(0).timeTo(1).direction('D').build()

errorFunc = (msg) ->
  console.log("Init.errorFunc " + msg)

func = (airportname) ->
  console.log("Init.func " + airportname)

Flight.fetchFlights(flightUrl, (data) ->
  console.log("Init.Flight.fetchFlights ")
  console.dir(data)

  Flight.getAirportNameById('OSL', func, errorFunc)
  #Flight.getAirportNameById('OSL', func, errorFunc)
  #Flight.getAirportNameById('CPH', func)
  #Flight.getAirportNameById('AAH', func)
  #Flight.getAirportNameById('AAH', func)
  #Flight.getAirportNameById('ACH', func)
)

###

#flightFactory = new FlightFactory.getInstance(url)

#window.onFlightLoadComplete= (data) =>
#  console.dir(data)
#  flight = flightFactory.getFlight('sK4759')
#  if flight?
#    console.log(flight[0].airport)

#console.log(url)