class window.UrlBuilder

  constructor: (@proxy, @url, airport) ->
    @url += "airport=" + airport.toUpperCase() + "&"

  timeFrom: (timeFrom) ->
    @url += "timeFrom=" + timeFrom + "&"
    return this;

  timeTo: (timeTo) ->
    @url += "timeTo=" + timeTo + "&"
    return this;

  direction: (direction) ->
    direction = direction.toUpperCase()
    if (direction is 'A' or direction is 'D')
      @url += "direction=" + direction + "&"
      return this;
    else
      throw new Error("Illegal direction (A or D is required, you entered #{direction})")

  lastUpdate: (lastUpdate) ->
    @url += "lastUpdate=" + lastUpdate + "&"
    return this;

  build: ->
    @url = encodeURIComponent(@url.substring(0, @url.lastIndexOf("&")))
    return @proxy + @url;