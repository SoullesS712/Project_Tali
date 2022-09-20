import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);
  @override
  State<Home> createState() => Map_State();
}

class Map_State extends State<Home> {
  final Completer<GoogleMapController> _controller = Completer();
  PolylinePoints polylinePoints = PolylinePoints();

  final Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polylineCoordinates = [];

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLicationIcon = BitmapDescriptor.defaultMarker;

  LocationData? currentLocation;

  static const LatLng sourceLocation = LatLng(14.026226, 99.982615);
  static const LatLng destination = LatLng(14.026757, 99.978281);
  Location location = Location();

  CameraPosition? initialCameraPosition;
  void initialLocation() async {
    location.getLocation().then(
      (currentLoc) {
        currentLocation = currentLoc;
        initialCameraPosition = CameraPosition(
          target: LatLng(currentLoc.latitude!, currentLoc.longitude!),
          zoom: 14.5,
          tilt: 59,
          bearing: -70,
        );
        location.onLocationChanged.listen((LocationData newLoc) async {
          currentLocation = newLoc;

          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(newLoc.latitude!, newLoc.longitude!),
                zoom: 14.5,
                tilt: 59,
                bearing: -70,
              ),
            ),
          );
          setState(() {});
        });
      },
    );
  }

  void getPolyPoints() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDN6tGyRHtw8bjXWdFn_QjBMGVkU70T7BQ",
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      optimizeWaypoints: true,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        },
      );
      setState(
        () {
          _polylines.add(
            Polyline(
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              jointType: JointType.round,
              geodesic: true,
              polylineId: const PolylineId("line"),
              width: 6,
              color: Colors.black,
              points: polylineCoordinates,
            ),
          );
        },
      );
    }
  }

  void setSourceAndDestinationIcons() async {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(24, 24)),
            'images/Pin_source.png')
        .then(
      (value) {
        sourceIcon = value;
      },
    );
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'images/Pin_destination.png')
        .then(
      (value) {
        destinationIcon = value;
      },
    );
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'images/Badge.png')
        .then(
      (value) {
        currentLicationIcon = value;
      },
    );
  }

  @override
  void initState() {
    initialLocation();
    getPolyPoints();
    setSourceAndDestinationIcons();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final drawerItems = ListView(
      children: [
        // ignore: prefer_const_constructors
        DrawerHeader(
          child:
              const Padding(padding: EdgeInsets.all(30.0), child: Text("Menu")),
        ),
        ListTile(
          title: const Text("Notification"),
          onTap: () {
            Navigator.pushNamed(context, "noti");
          },
        ),
        ListTile(
          title: const Text("Setting"),
          onTap: () {
            Navigator.pushNamed(context, "setting");
          },
        ),
        ListTile(
          title: const Text("How to Use"),
          onTap: () {
            Navigator.pushNamed(context, "howtouse");
          },
        ),
      ],
    );

    var container = Container(
      // ignore: prefer_const_constructors
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF54436B), Color(0xFF50CB93), Color(0xFFACFFAD)],
          begin: AlignmentDirectional(1, -0.44),
          end: AlignmentDirectional(-1, 0.44),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_forward_ios),
          color: Color(0xFF54436B),
        ),
        centerTitle: true,
        title: const Text(
          'Talibus',
          style: TextStyle(color: Color(0xFF54436B)),
        ),
        actions: [
          IconButton(
            icon: Image.asset('images/roadicon.png'),
            padding: EdgeInsets.all(10),
            onPressed: () {
              Navigator.pushNamed(context, "roadmap");
            },
            color: Color(0xFF54436B),
          ),
        ],
        flexibleSpace: container,
      ),
      body: currentLocation == null
          ? const Center(child: Text("Loading..."))
          : Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: GoogleMap(
                      zoomControlsEnabled: true,
                      initialCameraPosition: initialCameraPosition!,
                      polylines: _polylines,
                      markers: {
                        Marker(
                          markerId: const MarkerId("currentLocation"),
                          icon: currentLicationIcon,
                          position: LatLng(currentLocation!.latitude!,
                              currentLocation!.longitude!),
                        ),
                        Marker(
                          markerId: const MarkerId("source"),
                          icon: sourceIcon,
                          position: sourceLocation,
                        ),
                        Marker(
                          markerId: const MarkerId("destination"),
                          icon: destinationIcon,
                          position: destination,
                        ),
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),
                ),
              ],
            ),
      drawer: Drawer(child: drawerItems),
    );
  }
}
