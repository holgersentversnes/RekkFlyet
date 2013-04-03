class window.ResultScreen

  uiTrainTable             = '#trainTable'
  uiFlightInfo             = '#flightInfo'

  showTrainInResultList: (flightObject, trainArray) ->
    if flightObject?
      console.log("Flight from resultscreen: " + flightObject)
      $(uiFlightInfo).html('')
      console.dir(flightObject)
      $(uiFlightInfo).html('<label id="resultFlightContent">' + flightObject.flightId + ' - ' + flightObject.schedule_time + ' - ' + flightObject.airport + '</label>')

    if trainArray?  #_TRAINS_TO_SHOW_ARRAY
      console.dir(trainArray)
      $("#trainTableWrapper").html("")
      #$("#trainTableWrapper").append('<table id="trainTable"><thead>
      $(".resultTrainHeader").html("Avganger fra: <br/>" + trainArray[0].departureStation)
      table = '<table id="trainTable"><thead>
          <tr>
            <th data-priority="2">Avgang</th>
            <th data-priority="3">Ankomst</th>
            <th data-priority="4">Reisetid</th>
            <th data-priority="5">Tilgode</th>
          </tr>
        </thead>'


      tbody = table + '<tbody>'

      for t in trainArray
        if t?
          depTime = @createShortDate(t.departureTime)
          arrTime = @createShortDate(t.arrivalTime)
          travelTime = @calculateTravelTime(t.arrivalTime, t.departureTime)
          airportTime = @calculateAirportTime(t.arrivalTime, flightObject.scheduled_time_date)
          colorForTrain = @decideColorForTrain(airportTime)
          #$("#trainTableWrapper").append('<tr><td>farge</td><td>' + depTime + '</td><td>' + arrTime + '</td><td>Reisetid</td></tr>')
          tbody += '<tr><td>' + depTime + '</td><td>' + arrTime + '</td><td>' + travelTime + '</td><td style="background-color: ' + colorForTrain + ';">' + airportTime + 'min</td></tr>'
          console.log(t.arrivalStation)
        else
          console.log("TRAINS_TO_SHOW VAR UDEFINERT")

      tbody += '</tbody></table>'
      $("#trainTableWrapper").append(tbody)
      #$("#trainTableWrapper").append('</tbody>')
      #$("#trainTableWrapper").append('</table>')
    else
      console.log("Hide hele tabellen, vis en feilmelding")

  calculateTravelTime: (startTime, endTime) ->
    travelTime = endTime.getTime() - startTime.getTime()
    travelTime = travelTime / (1000 * 60)
    return Math.abs(travelTime) + "min"

  calculateAirportTime: (arrivalTime, flightDepartureTime) ->
    airportTime = flightDepartureTime.getTime() - arrivalTime.getTime()
    airportTime = airportTime / (1000 * 60)
    return Math.abs(airportTime)

  decideColorForTrain: (airportTime) ->
    color = null
    if airportTime >= 60
      color = "#78AB46" #green
    else if airportTime >= 45 and airportTime < 60
      color = "#E6F246" #yellow
    else if airportTime < 45 and airportTime >= 0
      color = "#F24738" #red
    return color

  createShortDate: (date) ->
    minutes = date.getMinutes()
    hours = date.getHours()

    day = date.getDay()
    month = date.getMonth() + 1

    if minutes < 10 then minutes = "0" + minutes
    if hours <10 then hours = "0" + hours

    if day < 10 then day = "0" + day
    if month < 10 then month = "0" + month

    #time = "Kl: " + hours + ":" + minutes + " - " + day + "/" + month
    time = hours + ":" + minutes
    return time
