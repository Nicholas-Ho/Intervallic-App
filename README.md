# Intervallic

The app is a reminder app with a focus on *intervallic reminders*. Users can set activities that they want to be reminded of (eg. Call Bob every 3 months, Pilates every day) and the app will push a notification whenever the time between the last instance of the activity exceeds a pre-determined interval.

## Background

The app aims to fill a gap in the lineup of current productivity/reminder apps. Current reminder apps generally focus on the following:

\-     Creating habits: Daily or Regular reminders. Generally, more focused on keeping streaks up.

\-     To-do List: Checkboxes of one-off to-do activities, such as shopping lists.

\-     Calendars: Reminder for one-off events. Generally, uses the format of a calendar.

The app aims to provide a framework for flexible, long-term planning and recurring long-term reminders.

The app is not date-specific, and assumes that for tasks assigned to the app, the more often, the better. It therefore does not penalize doing tasks early. The app should not be used as an alarm, or for time-specific reminders. The app is also not a deadline manager.

## Build Status

Ongoing.

## Framework Used

Intervallic is built on **Flutter**.

The app uses the **Provider** state management package and makes use of **SQFlite** for local data storage. Both packages are open-source.

## Navigating the Repository

Included packages can be found in `pubspec.yaml`.

The working folder is `lib`.

- The file `main.dart` contains the core of the application. The UI layer is written here.

-  The `utils` folder contains `DBHelper.dart` and `domain.dart`. Both files represent the data and domain layers respectively.

- The `models` folder contains `models.dart`, which houses the data models used.

## License

This project is private.

© Nicholas Ho