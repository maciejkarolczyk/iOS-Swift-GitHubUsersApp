# iOS-Swift-GitHubUsersApp

- application for iPhone and iPad displaying a list of github users and their details. The list of users should show up after searching
- The application will check if there is an Internet connection before making the query and will skip it when there is no chance of obtaining data from an external source
- Simple cache of the whole list and details already visited - implemented using Realm.

Portrait mode [iPhone],
Landscape mode [iPhone],
Portrait mode [tablet],
- displays a list -> after clicking on a list item it takes you to the details view

Landscape mode [tablet]
- displays the list and details -> after clicking on a list item in the view on the right, it loads the relevant details. By default, the first element of the list should be clicked in order not to display an empty field.
Left side of the list 50% | Right side details 50%

API:
https://developer.github.com/v3/

