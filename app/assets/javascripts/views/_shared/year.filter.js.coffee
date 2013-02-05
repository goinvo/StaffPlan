class StaffPlan.Views.Shared.YearFilter extends Support.CompositeView
  tagName: "li"
  className: "year-filter"
    
  initialize: ->
    @years = @options.years
    @parent = @options.parent

  events:
    "click a.filter": "updateYearFilter"

  updateYearFilter: (event) ->
    year = $(event.currentTarget).data().fy
    localStorage.setItem "yearFilter", year
    @parent.trigger "year:changed",
      year: year

  render: ->
    yearFilter = localStorage.getItem("yearFilter")
    @$el.html StaffPlan.Templates.Shared.yearFilter
      relevantYears: StaffPlan.relevantYears.sort()
      buttonText: "Showing: #{if(yearFilter == null || yearFilter == "all") then "All Fiscal Years" else "FY #{yearFilter}"}"
    
    @
