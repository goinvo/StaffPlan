class StaffPlan.View extends Support.CompositeView
  render: ->
    @$el.empty()
    
    @$el.html StaffPlan.Templates.Layouts.application
      currentUserId: StaffPlan.currentUser.id

    if StaffPlan.userCompanies.length > 1
      companySwitcher = new StaffPlan.Views.Shared.CompanySwitcher
      @$el.find('header .inner ul:first').append companySwitcher.render().el
    
    $( document.body ).trigger( 'view:rendered' );
