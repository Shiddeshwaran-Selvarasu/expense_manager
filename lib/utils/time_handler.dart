import 'package:intl/intl.dart';

class TimeHandler{
  String getTimeDiff(DateTime time){
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
}