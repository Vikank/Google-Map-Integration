import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map_integration/controllers/home_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatelessWidget {
  final HomeController homeController = Get.put(HomeController());

  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          GetBuilder<HomeController>(
            builder: (controller) {
              return GoogleMap(
                polylines: Set<Polyline>.of(homeController.polylines.values),
                markers: Set<Marker>.of(homeController.markers),
                onCameraIdle: homeController.showHiddenButton,
                onCameraMoveStarted: homeController.hideButton,
                zoomControlsEnabled: false,
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      homeController.lat.value, homeController.long.value),
                  zoom: 18.0,
                ),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 3.4), //(x,y)
                  blurRadius: 5.0,
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              title: TextFormField(
                cursorColor: Colors.grey,
                cursorHeight: 22,
                style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  homeController.destination.value = val;
                },
              ),
              trailing: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  await homeController.getAddress();
                  double miny = (homeController.startLatitude <=
                          homeController.destinationLatitude)
                      ? homeController.startLatitude
                      : homeController.destinationLatitude;
                  double minx = (homeController.startLongitude <=
                          homeController.destinationLongitude)
                      ? homeController.startLongitude
                      : homeController.destinationLongitude;
                  double maxy = (homeController.startLatitude <=
                          homeController.destinationLatitude)
                      ? homeController.destinationLatitude
                      : homeController.startLatitude;
                  double maxx = (homeController.startLongitude <=
                          homeController.destinationLongitude)
                      ? homeController.destinationLongitude
                      : homeController.startLongitude;

                  double southWestLatitude = miny;
                  double southWestLongitude = minx;

                  double northEastLatitude = maxy;
                  double northEastLongitude = maxx;

                  mapController.animateCamera(
                    CameraUpdate.newLatLngBounds(
                      LatLngBounds(
                        northeast:
                            LatLng(northEastLatitude, northEastLongitude),
                        southwest:
                            LatLng(southWestLatitude, southWestLongitude),
                      ),
                      100.0,
                    ),
                  );
                  await homeController.getPolyline();
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(() => Visibility(
            visible: homeController.showButton.value,
            child: FloatingActionButton(
              child: const Icon(Icons.my_location),
              backgroundColor: Colors.orange,
              onPressed: () {
                homeController.getCurrentLocation();
                mapController.animateCamera(CameraUpdate.newLatLngZoom(
                    LatLng(homeController.lat.value, homeController.long.value),
                    18.0));
              },
            ),
          )),
    );
  }
}
