_t =
  application: """
  <div id="wrap">
    <header>
      <div class="inner">
        <nav>
          <ul>
            <li id="nav-my-staff-plan"><a href="/staffplans/{{currentUserId}}">My StaffPlan</a></li>
            <li id="nav-all-staff"><a href="/staffplans">All StaffPlans</a></li>
            <li id="nav-clients"><a href="/clients">Clients</a></li>
            <li id="nav-projects"><a href="/projects">Projects</a></li>
          </ul>
        </nav>
        <div class="pull-right">
          <ul>
            <li>
              <form class="quick-jump">
                <input type="text" class="input search-query header-typeahead" placeholder="" />
              </form>
            </li>
            <li><a data-bypass href="mailto:staffplan-feedback@goinvo.com?subject=StaffPlan%20Feedback">Feedback</a></li>
            <li><a href="/sign_out" data-bypass>Sign Out</a></li>
          </ul>
        </div>
      </div>
    </header>
    <section class="main"></section>
    <div id="push"></div>
  </div>
  <footer>
    <ul>
      <li><a data-bypass href="https://github.com/rescuedcode/StaffPlan" target="_blank">Open Source</a></li>
      <li><a data-bypass href="https://www.pivotaltracker.com/projects/663621" target="_blank">Tracker</a></li>
      <li class="pull-right"><a data-bypass href="http://goinvo.com" target="_blank">by Involution Studios</a></li>
    </ul>
  </footer>
  """

StaffPlan.Templates.Layouts =
  application: Handlebars.compile _t.application

