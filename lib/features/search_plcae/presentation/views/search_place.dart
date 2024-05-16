import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_near_me/features/search_plcae/presentation/provider/search_location_provider.dart';
import 'package:travel_near_me/features/search_plcae/presentation/views/widgets/search_location.dart';

import 'widgets/address_form.dart';

class SearchPlaceScreen extends ConsumerStatefulWidget {
  const SearchPlaceScreen({super.key});

  @override
  ConsumerState<SearchPlaceScreen> createState() =>
      _SearchPlaceScreenConsumerState();
}

class _SearchPlaceScreenConsumerState extends ConsumerState<SearchPlaceScreen> {
  late BitmapDescriptor currentLocationPoint;
  late BitmapDescriptor dropLocation;

  final TextEditingController destinationController = TextEditingController();
  static CameraPosition _initialCameraPosition =
      const CameraPosition(target: LatLng(11.127123, 78.656891), zoom: 12);

  // final List<Marker> myMarker = [];
  // final List<Marker> markerList = [];
  // Directions directions = const Directions();
  late GoogleMapController _controller;
  bool isDirectionAvailable = true;
  late StreamSubscription<Position> streamSubscription;
  var latitude = '';
  var longitude = '';

  @override
  void initState() {
    super.initState();

    currentLocation();
    initialLocationMark();
    setCustomMarker(
        currentLocationPointIcon: "assets/icon/currect_location.png",
        dropLocationIcon: "assets/icon/drop_ic.png");
  }

  void setCustomMarker(
      {required String currentLocationPointIcon,
      required String dropLocationIcon}) async {
    if (currentLocationPointIcon != "") {
      currentLocationPoint = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(48, 48)),
          currentLocationPointIcon);
    }
    if (dropLocationIcon != "") {
      dropLocation = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(48, 48)), dropLocationIcon);
    }
  }

  /// Your Current Location
  getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    late LocationPermission permission;
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location Services are disabled');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permission are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location Permission are Permanently denied, we can't request permission.");
    }

    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      latitude = 'Latitude: ${position.latitude}';
      longitude = 'Longitude: ${position.longitude}';
      log("$latitude $longitude");
      LatLng? pickupGeometry;
      setState(() => {
            ref.read(searchLocationControllerProvider).setPickupGeometry(
                  LatLng(position.latitude, position.longitude),
                ),
            setPickAddressFromLocation(position.latitude, position.longitude),
            pickupGeometry =
                ref.watch(searchLocationControllerProvider).pickupGeometry,
            log("Pick$pickupGeometry"),
            initialLocationMark()
          });
    });
  }

  void setPickAddressFromLocation(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String pickAddress =
          "${placemark.name}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
      setPickupAddress(pickAddress);
    } else {
      throw Exception('No placemark found');
    }
  }

  void currentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 12,
      );
    });
  }

  void initialLocationMark() async {
    LatLng? pickUpGeometry =
        ref.read(searchLocationControllerProvider).pickupGeometry;
    LatLng? dropUpGeometry =
        ref.read(searchLocationControllerProvider).dropOffGeometry;

    getDirection(pickUpGeometry, dropUpGeometry);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setPickupAddress(String query) async {
    if (query != '') {
      ref.read(searchLocationControllerProvider).setPickupAddress(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickupAddress =
        ref.watch(searchLocationControllerProvider).pickupAddress;
    final dropOffAddress =
        ref.watch(searchLocationControllerProvider).dropOffAddress;
    LatLng? pickUpGeometry =
        ref.watch(searchLocationControllerProvider).pickupGeometry;
    LatLng? dropUpGeometry =
        ref.watch(searchLocationControllerProvider).dropOffGeometry;
    log("Drop$dropUpGeometry");
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: GoogleMap(
                      initialCameraPosition: _initialCameraPosition,
                      mapType: MapType.hybrid,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      markers: {
                        if (pickUpGeometry != null)
                          Marker(
                            markerId: const MarkerId("origin"),
                            draggable: true,
                            infoWindow: const InfoWindow(
                                title: 'origin', snippet: 'Origin'),
                            icon: currentLocationPoint,
                            position: pickUpGeometry,
                          ),
                        if (dropUpGeometry != null)
                          Marker(
                            markerId: const MarkerId("destination"),
                            draggable: true,
                            infoWindow: const InfoWindow(
                                title: 'destination', snippet: 'Destination'),
                            icon: dropLocation,
                            position: dropUpGeometry,
                          ),
                      },
                      circles: {
                        if (pickUpGeometry != null)
                          Circle(
                              circleId: const CircleId('origin'),
                              center: pickUpGeometry,
                              radius: 250,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                              fillColor: Colors.lightBlue.withOpacity(0.2)),
                        if (dropUpGeometry != null)
                          Circle(
                              circleId: const CircleId('destination'),
                              center: dropUpGeometry,
                              radius: 250,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                              fillColor: Colors.orange.withOpacity(0.2))
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                      }),
                ),
                Positioned(
                  left: 0.w,
                  right: 0.w,
                  top: 100.h,
                  child: Column(
                    children: [
                      searchTextFormField(
                          onPressed: () =>
                              showAddressModelFunc('alarm_location'),
                          locationIcon: Icons.search,
                          place: dropOffAddress ?? "Alarm location?"),
                    ],
                  ),
                ),
                Positioned(
                    top: 600,
                    bottom: 1,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        getCurrentLocation();
                      },
                      child: Container(
                        height: 65.h,
                        width: 65.w,
                        decoration: BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          Icons.my_location,
                          color: pickUpGeometry != null
                              ? Colors.orange
                              : Colors.black,
                        ),
                      ),
                    )),
                // Positioned(
                // bottom: 40.h,
                // left: 0.w,
                // right: 0.w,
                //   child: Container(
                //     height: 260.h,
                //     margin: EdgeInsets.only(left: 24.w, right: 24.w),
                //     decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: Dimensions.kBorderRadiusAllSmall),
                //     padding: Dimensions.kPaddingAllMedium,
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Text(
                //                 isDirectionAvailable == true
                //                     ? 'arround'
                //                     : "${directions.totalDuration}",
                //                 style: Theme.of(context).textTheme.titleMedium),
                //             Text(
                //                 isDirectionAvailable == true
                //                     ? '0 Km'
                //                     : "${directions.totalDistance}",
                //                 style: Theme.of(context).textTheme.titleLarge),
                //           ],
                //         ),
                // AddressFormField(
                //   onTap: () => showAddressModelFunc('pickup'),
                //   color: Colors.green,
                //   locationIcon: AppIcon.pickupLocation,
                //   isFirst: true,
                //   isLast: false,
                //   place: pickupAddress ?? 'Choose start location',
                // ),
                //         AddressFormField(
                //           onTap: () => showAddressModelFunc('drop_off'),
                //           color: Colors.red,
                //           locationIcon: AppIcon.dropLocation,
                //           place: dropOffAddress ?? 'Choose destination',
                //           isFirst: false,
                //           isLast: true,
                //         ),
                //         Dimensions.kSpacer,
                //         Button(
                //           onTap: () {
                //             Navigator.of(context).push(MaterialPageRoute(
                //                 builder: (context) => const ShowPlaceScreen()));
                //           },
                //           width: 2,
                //           text: 'Submit',
                //           backGroundColor: Colors.red,
                //           height: 40,
                //           textColor: Colors.white,
                //         )
                //       ],
                //     ),
                //   ),
                // )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showAddressModelFunc(String label) {
    if (label == 'alarm_location') {
      showModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        builder: (_) {
          return SearchLocationScreen(
            label: 'Alarm location?',
            controller: destinationController,
          );
        },
      ).then((value) async => {
            getDirection(
              ref.watch(searchLocationControllerProvider).pickupGeometry,
              ref.watch(searchLocationControllerProvider).dropOffGeometry,
            ),
          });
    }
    // if (label == 'drop_off') {
    //   showModalBottomSheet(
    //     context: context,
    //     enableDrag: false,
    //     isDismissible: false,
    //     isScrollControlled: true,
    //     builder: (_) {
    //       return SearchLocationScreen(
    //         label: 'Choose destination',
    //         controller: destinationController,
    //       );
    //     },
    //   ).then((value) async => {
    //         getDirection(
    //           ref.watch(searchLocationControllerProvider).pickupGeometry,
    //           // ref.watch(searchLocationControllerProvider).dropOffGeometry,
    //         ),
    //       });
    // }
  }

  Future<void> getDirection(LatLng? origin, LatLng? destination) async {
    if (origin != null) {
      log('${origin.latitude} ${origin.longitude}');
      setState(() {
        _controller.animateCamera(
          CameraUpdate.newLatLngZoom(
              LatLng(origin.latitude, origin.longitude), 16),
        );
      });
    }
    if (destination != null) {
      log('${destination.latitude} ${destination.longitude}');

      setState(() {
        _controller.animateCamera(
          CameraUpdate.newLatLngZoom(
              LatLng(destination.latitude, destination.longitude), 16),
        );
      });
      // ref
      //     .read(searchLocationProvider.notifier)
      //     .getDirection(DirectionEntities(
      //         radius: 100, destination: destination, key: ApiKey.placeApiKey))
      //     .then((res) => res.fold(
      //         (l) => {},
      //         (r) => {
      //               setState(() {
      //                 _controller.animateCamera(
      //                   CameraUpdate.newLatLngZoom(r, 100),
      //                 );
      //                 // updateDistance(r.totalDistance!);
      //                 // ref
      //                 //     .read(searchLocationControllerProvider)
      //                 //     .setDuration(r.totalDuration!);
      //                 isDirectionAvailable = false;
      //               }),
      //             }));
    }
  }

  void updateDistance(String response) async {
    List<String> stringList = response.split(" ");
    double doubleValue = double.parse(stringList[0]);
    int intValue = doubleValue.toInt();
    ref.read(searchLocationControllerProvider).setDistance(intValue);
  }
}
