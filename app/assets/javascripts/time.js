(function(){
    var Time = function(yearOrString, month, day, hour, minute, second, millisecond){
        if (typeof(yearOrString) === "string") {
            this.date = new Date(Date.parse(yearOrString));
        } else {
            if (yearOrString) {
                this.date = new Date(yearOrString, (month - 1 || 0), (day || 1), (hour || 0), (minute || 0), (second || 0), (millisecond || 0));
            } else {
                this.date = new Date();
            }
        }
    };

    Time.firstDayOfWeek = 0;
    var DAYS_IN_MONTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var MILLISECONDS_IN_WEEK = 604800000.0;
    var MILLISECONDS_IN_DAY = 86400000;
    var MILLISECONDS_IN_HOUR = 3600000;
    var THIRTY_TWO_DAYS = 2764800000;

    Time.prototype = {
        // Month gets special treatment, to avoid zero indexing from Date.
        month: function(value) {
            if (value) {
                this.date.setMonth(value - 1);
            } else {
                return this.date.getMonth() + 1;
            }
        },

        // The week number of the year, iso8601.
        week: function (value) {
            if (value) {
                throw new Error("Setting week number not implemented yet.");
            } else {
                // With thanks to http://github.com/jquery/jquery-ui/blob/37e8dd605da5d99600c0/ui/jquery.ui.datepicker.js#L919
                var checker = this.clone();
                checker.day(checker.day() + 4 - checker.weekday());
                var epoch = checker.epoch();
                checker.beginningOfYear();
                return Math.floor(Math.round((epoch - checker.epoch()) / MILLISECONDS_IN_DAY) / 7) + 1;
            }
        },
        
        // There is no setDay(), implementing that here.
        weekday: function(value) {
            if (value) {
                this.advanceDays(value - this.weekday());
            } else {
                var a = (this.date.getDay() - (this.firstDayOfWeek || Time.firstDayOfWeek));
                var b = 7;
                var ringModulo = a - Math.floor(a / b) * b;
                return ringModulo + 1;
            }
        },
        
        /////////////////////////////////////
        // Utility
        
        clone: function(){
            var newTime = new Time();
            newTime.epoch(this.epoch());
            newTime.firstDayOfWeek = this.firstDayOfWeek;

            return newTime;
        },

        isBefore: function(compare) {
            var timestamp = +compare || 'getTime' in compare && compare.getTime() || 'epoch' in compare && compare.epoch();
            return this.epoch() < timestamp;
        },

        isLeapYear: function(){
            var year = this.year();
            return (year % 4 === 0) && (year % 100 !== 0) || (year % 400 === 0);
        },

        daysInMonth: function(){
            if (this.month() === 2 && this.isLeapYear()) {
                return 29;
            }

            return DAYS_IN_MONTH[this.month() - 1];
        },

        weeksInMonth: function(){
            var millisecondsInThisMonth = this.clone().endOfMonth().epoch() - this.clone().firstDayInCalendarMonth().epoch();
            return Math.ceil(millisecondsInThisMonth / MILLISECONDS_IN_WEEK);
        },

        // The current week's index in weeksInMonth
        weekOfCurrentMonth: function(){
            // NFI how this works. The tests pass, and brute force ftw.
            return Math.floor((this.day() + this.clone().day(1).weekday() + 5) / 7);
        },

        firstDayInCalendarMonth: function(){
            this.beginningOfMonth();
            this.weekday(1);
            return this;
        },

        /////////////////////////////////////
        // Stepping
        beginningOfYear: function(){
            this.month(1); this.beginningOfMonth();
            return this;
        },

        beginningOfMonth: function(){
            this.day(1); this.beginningOfDay();
            return this;
        },

        beginningOfWeek: function(){
            this.weekday(1); this.beginningOfDay();
            return this;
        },

        beginningOfDay: function(){
            this.hour(0); this.beginningOfHour();
            return this;
        },

        beginningOfHour: function(){
            this.minute(0); this.beginningOfMinute();
            return this;
        },

        beginningOfMinute: function(){
            this.second(0); this.millisecond(0);
            return this;
        },

        // ------------

        endOfYear: function(){
            this.month(12); this.endOfMonth();
            return this;
        },

        endOfMonth: function(){
            this.day(this.daysInMonth()); this.endOfDay();
            return this;
        },

        endOfWeek: function(){
            this.weekday(7); this.endOfDay();
            return this;
        },

        endOfDay: function(){
            this.hour(23); this.endOfHour();
            return this;
        },

        endOfHour: function(){
            this.minute(59); this.endOfMinute();
            return this;
        },

        endOfMinute: function(){
            this.second(59);
            return this;
        },

        // ------------

        nextWeek: function(){
            this.epoch(this.endOfWeek().epoch() + MILLISECONDS_IN_DAY);
            this.beginningOfWeek();
            return this;
        },

        nextMonth: function(){
            this.epoch(this.beginningOfMonth().epoch() + THIRTY_TWO_DAYS);
            this.beginningOfMonth();
            return this;
        },

        previousWeek: function(){
            this.epoch(this.beginningOfWeek().epoch() - 1);
            this.beginningOfWeek();
            return this;
        },

        previousMonth: function(){
            this.epoch(this.beginningOfMonth().epoch() - 1);
            this.beginningOfMonth();
            return this;
        },

        // ------------

        advanceDays: function(days) {
            this.beginningOfDay();
            // Adding 1 hour, in case this is a day where daylight savings change
            this.epoch(this.epoch() + (MILLISECONDS_IN_DAY * days) + MILLISECONDS_IN_HOUR);
            this.beginningOfDay();

            return this;
        },

        advanceWeeks: function(weeks) {
            var dir = weeks > 0 ? "next" : "previous",
                i = 0;
            for (i; i < Math.abs(weeks); i++)
                this[dir + "Week"]();
            // this.epoch(this.epoch() + (MILLISECONDS_IN_WEEK * weeks));
            // this.beginningOfWeek();

            return this;
        },

        advanceMonths: function(months) {
            var base = this.year() * 12 + (this.month() - 1) + months;
            var newYear = Math.floor(base / 12);
            var newMonth = (base % 12) + 1;

            // Setting the month to '2' on january 31th
            // gives us march 2nd. Circumventing this.
            var newTime = new Time(newYear, newMonth);
            var daysInNewTimeMonth = newTime.daysInMonth();

            if (this.day() > daysInNewTimeMonth) {
                this.year(newYear);
                this.day(1);
                this.month(newMonth);
                this.day(daysInNewTimeMonth);
            } else {
                this.year(newYear);
                this.month(newMonth);
            }

            return this;
        },


        // ------------

        toString: function() {
            return [this.year(), this.month(), this.day()].join(".") + " " + [this.hour(), this.minute(), this.second()].join(":");
        }
    };
    
    /////////////////////////////////////
    // The accessors. Uses the same function for both getting and
    // setting, e.g. year() to get and year(2005) to set.
    Time.accessor = function(name, dateFunctionName){
        Time.prototype[name] = function(value) {
            if (value !== undefined) {
                this.date["set" + dateFunctionName](value);
                return this;
            } else {
                return this.date["get" + dateFunctionName]();
            }
        };
    };
    
    Time.accessor("year", "FullYear");
    // month: see below
    Time.accessor("day", "Date");
    Time.accessor("hour", "Hours");
    Time.accessor("minute", "Minutes");
    Time.accessor("second", "Seconds");
    Time.accessor("millisecond", "Milliseconds");
    // weekday: See below
    Time.accessor("epoch", "Time");

    // Todo: Some kind of noConflict() thing, in case people have a 'Time' around already.
    window.Time = Time;
})();
