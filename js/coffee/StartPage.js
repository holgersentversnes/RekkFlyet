// Generated by CoffeeScript 1.6.1
(function() {

  window.StartPage = (function() {
    var currentSearchValue, flightManager, instance, uiBaggageCheckinId, uiBaggageDivId, uiBaggageNonCheckinId, uiFlightListId, uiFlightNotificationLabelId, uiFlightSearchDivId, uiFlightSearchId;

    StartPage._UI_FLIGHT_LIST = "flightList";

    StartPage._UI_FLIGHT_NOTIFICATION_LABEL = "flightNotificationLabel";

    StartPage._UI_FLIGHT_SEARCH_INPUT = "searchFlights";

    StartPage._UI_FLIGHT_PAGE_DIV = "StartPageFlightContent";

    StartPage._UI_BAGGAGE_DIV = "StartPageBaggageContent";

    StartPage._UI_BAGGAGE_CHECKIN = "baggage_checkin";

    StartPage._UI_BAGGAGE_NONCHECKIN = "baggage_nocheckin";

    StartPage._FLIGHT_LIST_MAX_COUNT = 5;

    flightManager = new FlightManager();

    instance = null;

    currentSearchValue = "";

    uiFlightListId = '#' + StartPage._UI_FLIGHT_LIST;

    uiFlightSearchId = '#' + StartPage._UI_FLIGHT_SEARCH_INPUT;

    uiFlightSearchDivId = '#' + StartPage._UI_FLIGHT_PAGE_DIV;

    uiFlightNotificationLabelId = '#' + StartPage._UI_FLIGHT_NOTIFICATION_LABEL;

    uiBaggageDivId = '#' + StartPage._UI_BAGGAGE_DIV;

    uiBaggageCheckinId = '#' + StartPage._UI_BAGGAGE_CHECKIN;

    uiBaggageNonCheckinId = '#' + StartPage._UI_BAGGAGE_NONCHECKIN;

    function StartPage() {
      flightManager = new FlightManager();
      flightManager.fetchFlights(this.fetchFlightsCallback, this.errorCallback);
      this.hideStepTwo();
    }

    /*
      Shows the list of available flights
    */


    StartPage.prototype.showStepOne = function() {
      $(uiFlightSearchDivId).show();
      return $(uiFlightSearchId).on('keyup', function() {
        return instance.onFlightSearchChange($(uiFlightSearchId).val());
      });
    };

    /*
      Hides the list of available flights
    */


    StartPage.prototype.hideStepOne = function() {
      $(uiFlightSearchDivId).hide();
      return $(uiFlightSearchId).unbind('keyup');
    };

    /*
      Shows the baggage options and the train station "picker"
    */


    StartPage.prototype.ShowStepTwo = function() {
      return $(uiBaggageDivId).show();
    };

    /*
      Hides the baggage options and the train station "picker"
    */


    StartPage.prototype.hideStepTwo = function() {
      return $(uiBaggageDivId).hide();
    };

    /*
      Event that gets fired on search field change/key up
    */


    StartPage.prototype.onFlightSearchChange = function(newVal) {
      var e, newFlights, _i, _len;
      try {
        if ((newVal == null) || (flightManager == null)) {
          throw new Error('Something went wrong');
        }
        newVal = newVal.trim();
        if (newVal === currentSearchValue) {
          return;
        }
        $(uiFlightListId).empty();
        $(uiFlightNotificationLabelId).text('');
        if (newVal.length > 0 && $(uiFlightListId).is(':visible')) {
          newFlights = flightManager.getFlightsById(newVal, StartPage._FLIGHT_LIST_MAX_COUNT);
          console.dir(newFlights);
          if (newFlights.length === StartPage._FLIGHT_LIST_MAX_COUNT) {
            $(uiFlightNotificationLabelId).text('Rafiner søket for flere resultater');
          } else if (newFlights.length === 0) {
            $(uiFlightNotificationLabelId).text('Fant ingen fly med koden ' + newVal);
          } else if (newFlights.length === 1 && currentSearchValue !== newVal && newVal.length >= currentSearchValue.length) {
            StartPage.getInstance().onFlightSelected(newFlights[0].flightId);
            currentSearchValue = newFlights[0].flightId;
            return;
          }
          for (_i = 0, _len = newFlights.length; _i < _len; _i++) {
            e = newFlights[_i];
            if (e != null) {
              $(uiFlightListId).append('<li id=' + e.flightId + '><table class="flightSearchResultElement"><tr><td>' + e.flightId + '</td><td>' + e.schedule_time + '</td><td>' + e.airport + '</td></tr></table></li>');
            }
          }
          $(uiFlightListId).delegate('li', 'click', function(val) {
            val = val['currentTarget']['id'];
            return StartPage.getInstance().onFlightSelected(val);
          });
          $(uiFlightListId).listview('refresh');
          return currentSearchValue = newVal;
        }
      } catch (error) {
        return this.errorCallback(error);
      }
    };

    /*
      Executed when the user presses a flight in the list or types the whole name.
    */


    StartPage.prototype.onFlightSelected = function(val) {
      $(uiFlightSearchId).val(val);
      StartPage.getInstance().hideStepOne();
      StartPage.getInstance().ShowStepTwo();
      return $(uiFlightSearchId).on('keyup', function() {
        if ($(uiFlightSearchId).val().trim() !== currentSearchValue) {
          $(uiFlightSearchId).unbind('keyup');
          StartPage.getInstance().showStepOne();
          StartPage.getInstance().onFlightSearchChange(val);
          return StartPage.getInstance().hideStepTwo();
        }
      });
    };

    StartPage.prototype.fetchFlightsCallback = function(flightArray) {
      return console.dir(flightArray);
    };

    StartPage.prototype.errorCallback = function(error) {
      return console.error(error);
    };

    StartPage.getInstance = function() {
      return instance != null ? instance : instance = new StartPage();
    };

    return StartPage;

  })();

}).call(this);
