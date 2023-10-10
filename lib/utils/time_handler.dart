import 'package:intl/intl.dart';

class DateTimeHandler{
  static const List<String> weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  static String getDateTimeDiff(DateTime time){
    if(time.difference(DateTime.now()).inMinutes.abs() < 1){
      return "Just Now";
    } else if(time.difference(DateTime.now()).inMinutes.abs() < 60){
      return "${time.difference(DateTime.now()).inMinutes.abs()} minutes ago";
    } else if(time.difference(DateTime.now()).inHours.abs() < 2){
      return "${time.difference(DateTime.now()).inHours.abs()} hour ago";
    } else if(time.difference(DateTime.now()).inDays.abs() == 0){
      return DateFormat.jm().format(time);
    } else if(time.difference(DateTime.now()).inDays.abs() == 1){
      return "Yesterday";
    } else {
      return DateFormat.yMMMMd('en_US').format(time);
    }
  }

  static String getTimeDiff(DateTime time){
    if(time.difference(DateTime.now()).inMinutes.abs() < 2){
      return "Just Now";
    } else if(time.difference(DateTime.now()).inMinutes.abs() < 60){
      return "${time.difference(DateTime.now()).inMinutes.abs()} minutes ago";
    } else if(time.difference(DateTime.now()).inHours.abs() < 2){
      return "${time.difference(DateTime.now()).inHours.abs()} hour ago";
    } else {
      return DateFormat.jm().format(time);
    }
  }

  static String getDateDiff(DateTime time){
    var date = DateTime(time.year, time.month, time.day);
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    if(date.difference(today).inDays.abs() < 1) {
      return "Today";
    } else if(date.difference(today).inDays.abs() < 2) {
      return "Yesterday";
    } else if(date.difference(today).inDays.abs() < 7){
      return weekDays[date.weekday-1];
    } else {
      return DateFormat.yMMMMd('en_US').format(time);
    }
  }
}