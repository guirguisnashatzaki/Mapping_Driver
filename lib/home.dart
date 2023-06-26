import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  String mail;
  Home({Key? key,required this.mail}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String? _currentAddress;
  Position? _currentPosition;
  FirebaseDatabase database = FirebaseDatabase.instance;
  bool isStopped = false;
  Duration oneSec = const Duration(seconds:15);



  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
     LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() async {
        _currentPosition = position;
        _getAddressFromLatLng(_currentPosition!);

        DatabaseReference ref = database.ref("users");

        await ref.set({
          "Lat": position.latitude,
          "long": position.longitude,
        });

      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = place.street! + " " + place.subLocality.toString() + " " + place.subAdministrativeArea.toString();
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('LAT: ${_currentPosition?.latitude ?? ""}'),
            Text('LNG: ${_currentPosition?.longitude ?? ""}'),
            Text('ADDRESS: ${_currentAddress ?? ""}'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: (){
                setState(() {
                  isStopped = false;
                });
                Timer.periodic(oneSec, (Timer t){
                  _getCurrentPosition();
                  if(isStopped){
                    t.cancel();
                  }
                });
              },
              child: const Text("Start tracking"),
            ),
            ElevatedButton(
              onPressed: (){
                setState(() {
                  isStopped = true;
                });
              },
              child: const Text("Stop tracking"),
            )
          ],
        ),
      ),
    );
  }
}