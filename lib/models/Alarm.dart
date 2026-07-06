import 'package:flutter/material.dart';

class Alarm {
  int? id;
  TimeOfDay alarmTime;
  String? title;
  bool isActive;
  bool isDaily;
  int daysMask;
  String sound;
  int locationId; // 🔥 যোগ করা হলো (অ্যান্ড্রয়েড ডাটাবেজের সাথে মিল রেখে)

  Alarm({
    this.id,
    required this.alarmTime,
    this.title,
    this.isActive = true,
    this.isDaily = true,
    this.daysMask = 127,
    this.sound = 'alarm.mp3',
    required this.locationId, // 🔥 এটি রিকোয়ার্ড (Required) করা হয়েছে
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hour': alarmTime.hour, // সরাসরি hour পাঠানো নেটিভের জন্য সুবিধা
      'minute': alarmTime.minute, // সরাসরি minute পাঠানো নেটিভের জন্য সুবিধা
      'title': title,
      'isActive': isActive, // নেটিভ এখন বুলিয়ান হ্যান্ডেল করছে
      'isDaily': isDaily,
      'daysMask': daysMask,
      'sound': sound,
      'locationId': locationId, // 🔥 ম্যাপে যোগ করা হলো
    };
  }

  factory Alarm.fromMap(Map<dynamic, dynamic> map) {
    // নেটিভ থেকে ডাটা সাধারণত 'hour' এবং 'minute' আলাদাভাবে আসে
    // যদি 'alarmTime' স্ট্রিং হিসেবে আসে তবে আপনার আগের লজিক কাজ করবে
    // তবে আপনার নেটিভ লজিক অনুযায়ী নিচে কনভার্ট করা হলো:

    TimeOfDay parsedTime;
    if (map['hour'] != null && map['minute'] != null) {
      parsedTime = TimeOfDay(hour: map['hour'], minute: map['minute']);
    } else {
      // ব্যাকআপ লজিক যদি স্ট্রিং হিসেবে আসে (যেমন: "10:30")
      final List<String> timeParts = (map['alarmTime'] as String).split(':');
      parsedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

    return Alarm(
      id: map['id'] as int?,
      alarmTime: parsedTime,
      title: map['title'] as String?,
      isActive: map['isActive'] == true || map['isActive'] == 1,
      isDaily: map['isDaily'] == true || map['isDaily'] == 1,
      daysMask: map['daysMask'] as int,
      sound: map['sound'] as String? ?? 'alarm.mp3',
      locationId: map['locationId'] as int? ?? 0, // 🔥 রিসিভ করা হলো
    );
  }

  @override
  String toString() {
    return 'Alarm{id: $id, alarmTime: ${alarmTime.hour}:${alarmTime.minute}, title: $title, isActive: $isActive, isDaily: $isDaily,daysMask: $daysMask, sound: $sound, locationId: $locationId}';
  }
}
