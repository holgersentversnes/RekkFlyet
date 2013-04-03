class window.ResultScreen

  uiTrainShowList             = '#trainList'
  uiFlightInfo                = '#flightInfo'

  showTrainInResultList: (flightObject, trainArray) ->
    if flightObject?
      console.log("Flight from resultscreen: " + flightObject)
      $(uiFlightInfo).html('')
      $(uiFlightInfo).html('<label>' + flightObject.flightId + ' - ' + flightObject.schedule_time + ' - ' + flightObject.airport + '</label>')

    if trainArray?  #_TRAINS_TO_SHOW_ARRAY
      $(uiTrainShowList).html('')
      console.dir(trainArray)
      for t in trainArray
        if t?
          $(uiTrainShowList).append('<li><table class="trainResultElement"><tr><td>FARGE</td><td>' + t.departureStation + '</td><td>' + t.departureTime + '</td><td>' + t.arrivalStation + '</td><td>' + t.arrivalTime + '</td></tr></table></li>')
        else
          console.log("TRAINS_TO_SHOW VAR UDEFINERT")


  createShortDate: (date) ->
