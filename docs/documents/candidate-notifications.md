# Candidate notifications

The service can display a notification on the service start page. The notification is displayed above the content of the page and below the GOV UK header and phase banner.

The content can be edited from within the template [app/views/shared/candidates/_alert_notification.html.erb](../app/views/shared/candidates/_alert_notification.html.erb).

The template is loaded in from within the views and whether the notification is displayed is controlled centrally by the `ApplicationController` but can be overridden by any inheriting `Controller`. If the notification needs to be turned of globally the file [app/controllers/application_controller.rb](../app/controllers/application_controller.rb#L37) will need to be set to `false`. 
