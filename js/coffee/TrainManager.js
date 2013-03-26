// Generated by CoffeeScript 1.6.1
(function() {
  var Train;

  window.TrainManager = (function() {
    var _USER_TIME_FROM_FLIGHT, _USER_TRAIN_STATION_ID;

    function TrainManager() {}

    TrainManager._TRAIN_ARRAY;

    _USER_TRAIN_STATION_ID = 0;

    _USER_TIME_FROM_FLIGHT = 0;

    TrainManager._RUTER_TRAIN_URL = "http://freberg.org/jsonpproxy.php?url=";

    TrainManager._CHOSEN_FLIGHT_FROM_START_PAGE = null;

    TrainManager.prototype.setUserTrainStationID = function(trainStationID) {
      return _USER_TRAIN_STATION_ID = trainStationID;
    };

    TrainManager.prototype.setUserTimeFromFlight = function(flightTime) {
      return _USER_TIME_FROM_FLIGHT = flightTime;
    };

    TrainManager.prototype.createEncodedProxyURL = function(trainStationID, flightObject) {
      this.setUserTrainStationID(trainStationID);
      this.setUserTimeFromFlight(flightObject);
      if (_USER_TRAIN_STATION_ID !== 0 && _USER_TIME_FROM_FLIGHT !== 0) {
        return TrainManager._RUTER_TRAIN_URL += encodeURIComponent("http://api-test.trafikanten.no/TravelStage/GetDeparturesAdvanced/" + _USER_TRAIN_STATION_ID + "?time=" + _USER_TIME_FROM_FLIGHT + "&lines=FT&transporttypes=AirportTrain&proposals=1");
      }
    };

    TrainManager.prototype.fetchTrains = function(trainStationID, flightObject) {
      this.createEncodedProxyURL(trainStationID, flightObject);
      return jQuery.ajax({
        url: TrainManager._RUTER_TRAIN_URL,
        dataType: 'jsonp',
        jsonp: 'jsonp',
        jsonpCallback: 'jsonpCallback',
        error: function(a, b, e) {
          return console.log("Errorz: " + e);
        },
        success: function(data) {
          var arrTime, depTime, returnData, t, timeTemp, train, _i, _len;
          returnData = JSON.parse(data);
          TrainManager._TRAIN_ARRAY = new Array();
          for (_i = 0, _len = returnData.length; _i < _len; _i++) {
            t = returnData[_i];
            train = new Train(t);
            timeTemp = train.departureTime.substr(6, 19);
            depTime = new Date(parseInt(timeTemp));
            train.departureTime = depTime;
            timeTemp = train.arrivalTime.substr(6, 19);
            arrTime = new Date(parseInt(timeTemp));
            train.arrivalTime = arrTime;
            TrainManager._TRAIN_ARRAY.push(train);
          }
          console.log(TrainManager._TRAIN_ARRAY.length);
          return {
            complete: function() {
              return this.getPossibleTrainList(trainStationID, flightObject);
            }
          };
        }
      });
    };

    TrainManager.prototype.getPossibleTrainList = function(trainStationID, flightObject) {
      if (flightObject != null) {
        console.log("asdl");
      }
      return console.log("LOL");
    };

    return TrainManager;

  })();

  Train = (function() {

    function Train(trainObject) {
      this.departureStation = trainObject['DepartureStop']['Name'];
      this.departureTime = trainObject['ActualTime'];
      this.arrivalStation = trainObject['Destination'];
      this.arrivalTime = trainObject['ArrivalTime'];
    }

    return Train;

  })();

}).call(this);
