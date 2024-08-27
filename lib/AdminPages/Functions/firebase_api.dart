

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi{
  final _firebasemessaging = FirebaseMessaging.instance;
final navigatorKey = GlobalKey<NavigatorState>();
  final androidChannel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notification',
  description: 'this channel is used for importance Notification',
    importance: Importance.defaultImportance,
  );

  final _localNotification = FlutterLocalNotificationsPlugin();

 

  Future<void> handleBackgroundMessage(RemoteMessage message) async{
    print('Title :  ${message.notification?.title}');
    print('Body :  ${message.notification?.body}');
    print('Payload:  ${message.data}');

  }



Future<void> initNotification() async{
      await _firebasemessaging.requestPermission();
      final FCmToken = await _firebasemessaging.getToken();
      print('token :   $FCmToken');

      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

}


}