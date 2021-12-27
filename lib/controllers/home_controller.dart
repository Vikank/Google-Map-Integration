
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeController extends GetxController {
  var long = 0.0.obs;
  var lat = 0.0.obs;
  var showButton = false.obs;
  var destination = ''.obs;
  var kGoogleApiKey = "AIzaSyByiVixTGQ5HlMs-zDI7oicqOpmi8zEklA";
  var startAddress = '';
  var _currentAddress = '';
  double startLatitude = 0.0;
  double startLongitude = 0.0;
  double destinationLatitude = 0.0;
  double destinationLongitude = 0.0;
  var startCoordinatesString = ''.obs;
  var destinationCoordinatesString = ''.obs;
  late Marker startMarker;
  late Marker destinationMarker;

  Set<Marker> markers = {};

  @override
  void onInit() {
  // TODO: implement onInit
  getCurrentLocation();
  super.onInit();
  }

  void hideButton() {
  showButton.value = false;
  }

  void showHiddenButton() {
  showButton.value = true;
  }

  void getCurrentLocation() {
  Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
      .then((Position position) {
  lat.value = position.latitude;
  long.value = position.longitude;
  });
  }

  PolylinePoints polylinePoints = PolylinePoints();

// List of coordinates to join
  List<LatLng> polylineCoordinates = [];

// Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};

  // Create the polylines for showing the route between two places

  void addPolyLine() {
  PolylineId id = PolylineId("poly");
  Polyline polyline = Polyline(
  polylineId: id,
  color: Colors.red,
  points: polylineCoordinates,
  );
  polylines[id] = polyline;
  update();
  }

  Future<void> getPolyline() async {
  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  kGoogleApiKey,
  PointLatLng(startLatitude, startLongitude),
  PointLatLng(destinationLatitude, destinationLongitude),
  travelMode: TravelMode.driving,
  );

  print(result.points);

  if (result.points.isNotEmpty) {
  result.points.forEach((PointLatLng point) {
  polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  });
  }
  addPolyLine();
  }

  Future<void> getAddress() async {
  try {
  if (markers.isNotEmpty) markers.clear();
  // Places are retrieved using the coordinates
  List<Placemark> p = await placemarkFromCoordinates(lat.value, long.value);

  // Taking the most probable result
  Placemark place = p[0];

  // Structuring the address
  _currentAddress =
  "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";

  // Setting the user's present location as the starting address
  startAddress = _currentAddress;

  // List<Location> startPlacemark = await locationFromAddress(startAddress);
  List<Location> destinationPlacemark =
  await locationFromAddress(destination.value);

  // Storing latitude & longitude of start and destination location
  startLatitude = lat.value;
  startLongitude = long.value;
  destinationLatitude = destinationPlacemark[0].latitude;
  destinationLongitude = destinationPlacemark[0].longitude;

  startCoordinatesString.value = '($startLatitude}, $startLongitude)';
  destinationCoordinatesString.value =
  '($destinationLatitude, $destinationLongitude)';

  // Start Location Marker
  startMarker = Marker(
  markerId: MarkerId(startCoordinatesString.value),
  position: LatLng(startLatitude, startLongitude),
  icon: BitmapDescriptor.defaultMarkerWithHue(20),
  );

  // Destination Location Marker
  destinationMarker = Marker(
  markerId: MarkerId(destinationCoordinatesString.value),
  position: LatLng(destinationLatitude, destinationLongitude),
  icon: BitmapDescriptor.defaultMarker,
  );

  markers.add(startMarker);
  markers.add(destinationMarker);
  } catch (e) {
  print(e);
  }
  update();
  }

}
