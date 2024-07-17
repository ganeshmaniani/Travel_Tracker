import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_polyline_points_plus/flutter_polyline_points_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:travel_near_me/core/utils/logger.dart';
import 'package:travel_near_me/features/place_list/presentation/view/place_list_ui.dart';
import 'package:travel_near_me/features/search_place/presentation/views/widgets/address_field_container.dart';
import 'package:travel_near_me/features/search_place/presentation/views/widgets/show_radius_bottom_sheet.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/app_key.dart';
import '../../../../core/notification_service/notification_service.dart';
import '../../data/model/auto_complete_prediction_model.dart';
import '../../data/model/place_to_geocode_model.dart';
import '../../domain/entities/alarm_entities.dart';
import '../../domain/entities/place_entities.dart';
import '../../domain/entities/place_to_geocode_entities.dart';
import '../provider/search_location_provider.dart';

class SearchPlaceScreen extends ConsumerStatefulWidget {
  const SearchPlaceScreen({super.key});

  @override
  ConsumerState<SearchPlaceScreen> createState() =>
      _SearchPlaceScreenConsumerState();
}

class _SearchPlaceScreenConsumerState extends ConsumerState<SearchPlaceScreen> {
  late BitmapDescriptor searchLocationMarker;

  final TextEditingController searchPlaceController = TextEditingController();
  final TextEditingController alarmNameController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  LocationData? currentLocationData;
  Timer? _distanceCheckTimer;

  StreamSubscription<Position>? streamSubscription;

  final player = AudioPlayer();

  List<Predictions> predictionsList = [];
  List<GeocodeList> geocodeList = [];

  // Markers to show points on the map
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  PolylinePoints polylinePoints = PolylinePoints();

  Completer<GoogleMapController> _controller = Completer();

  ScrollController scrollController = ScrollController();
  final FlutterBackgroundService service = FlutterBackgroundService();
  final NotificationService notificationService = NotificationService();
  late StreamSubscription<String> _notificationSubscription;

  final NotificationBarService _notificationBarService =
      NotificationBarService();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await notificationService.initNotification();
    notificationService.stopDistanceCheckCallback = stopDistanceCheck;
    notificationService.actionStream.listen((action) {
      if (action == 'stop') {
        stopDistanceCheck();
      }
    });
    getCurrentLocations();
    setCustomMarker(searchLocationIcon: "assets/icon/drop_ic.png");
    placesAutoComplete(searchPlaceController.text);
    // Initialize other stuff like markers, getting current location etc.
  }

  /// Search the Place
  void placesAutoComplete(String query) async {
    ref.read(searchLocationControllerProvider).setLoading(true);
    ref
        .read(searchLocationProvider.notifier)
        .autoCompletePlaceList(
            PlaceEntities(query: query, key: ApiKey.placeApiKey))
        .then((res) => res.fold(
            (l) => {
                  predictionsList = [],
                  ref.read(searchLocationControllerProvider).setLoading(false)
                },
            (r) => {
                  predictionsList = r.predictions ?? [],
                  ref.read(searchLocationControllerProvider).setLoading(false)
                }));
  }

  /// PlaceId To Get Latitude Longitude
  void placeIdToGeocode(String placeId) async {
    ref
        .read(searchLocationProvider.notifier)
        .placeToGeocode(
            PlaceToGeocodeEntities(placeId: placeId, key: ApiKey.placeApiKey))
        .then((res) => res.fold(
            (l) => {
                  geocodeList = [],
                },
            (r) => {
                  geocodeList = r.geocode ?? [],
                  getLatLong(geocodeList),
                }));
  }

  void setPickupAddress(String query) async {
    if (query != '') {
      ref.read(searchLocationControllerProvider).setPickupAddress(query);
    }
  }

  void getLatLong(List<GeocodeList> geocode) {
    Geometry val = geocode[0].geometry!;
    GoogleMapController? googleMapController =
        ref.watch(searchLocationControllerProvider).googleMapController;

    setState(() {
      ref.read(searchLocationControllerProvider).setEndLat(val.location!.lat!);
      ref.read(searchLocationControllerProvider).setEndLong(val.location!.lng!);
      ref
          .read(searchLocationControllerProvider)
          .setPickupGeometry(LatLng(val.location!.lat!, val.location!.lng!));
      googleMapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
            LatLng(val.location!.lat!, val.location!.lng!), 18),
      );
      showRadiusSelectedBottomSheet(context);
    });

    // Log.d("${val.location!.lat!}, ${val.location!.lng!}");
  }

  void setCustomMarker({required String searchLocationIcon}) async {
    if (searchLocationIcon != "") {
      searchLocationMarker = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(48, 48)), searchLocationIcon);
    }
  }

  void showRadiusSelectedBottomSheet(BuildContext context) {
    double alertRadius =
        ref.watch(searchLocationControllerProvider).alertRadius;
    bool isEntryMode = ref.read(searchLocationControllerProvider).isEntryMode;
    showModalBottomSheet(
      // enableDrag: false,
      isDismissible: false,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return ShowRadiusBottomSheet(
          alertRadius: alertRadius,
          onRadiusChanged: (double value) {
            ref.read(searchLocationControllerProvider).setAlertRadius(value);
            Log.d('Selected Radius: ${value.toString()}');
            updateMapZoom(value);
          },
          startOnPressed: () async {
            FlutterBackgroundService().invoke('setAsBackground');
            checkDistance();
            _getPolyline();
            Navigator.pop(context);
          },
          onPressedEntry: () {
            ref.read(searchLocationControllerProvider).setIsEntryMode(true);
            Log.i("DEBUG - Entry Mode Set to: true");
          },
          onPressedExit: () {
            ref.read(searchLocationControllerProvider).setIsEntryMode(false);
            Log.i("DEBUG - Entry Mode Set to: false");
          },
          isEntryMode: isEntryMode,
          cancelOnPressed: () {
            Navigator.pop(context);
            stopDistanceCheck();
          },
          alarmNameController: alarmNameController,
          confirmOnPressed: () async {
            final placeLatitude =
                ref.watch(searchLocationControllerProvider).endLat!;
            final placeLongitude =
                ref.watch(searchLocationControllerProvider).endLong!;
            String placeDescription =
                ref.read(searchLocationControllerProvider).pickupAddress!;

            bool isEntryMode =
                ref.read(searchLocationControllerProvider).isEntryMode;
            AlarmEntities addAlarmEntities = AlarmEntities(
              alarmName: alarmNameController.text,
              alertRadius: alertRadius,
              placeDescription: placeDescription,
              placeLatitude: placeLatitude,
              placeLongitude: placeLongitude,
              isEntryMode: isEntryMode,
            );
            final response = ref
                .read(searchLocationProvider.notifier)
                .addAlarm(addAlarmEntities);
            response.then((response) =>
                response.fold((l) => Log.d(l.message.toString()), (r) {
                  checkDistance();
                  Navigator.pop(context);
                }));
          },
        );
      },
    );
  }

  void updateMapZoom(double radius) {
    GoogleMapController? mapController =
        ref.read(searchLocationControllerProvider).googleMapController;
    LatLng? center = ref.read(searchLocationControllerProvider).pickupGeometry;

    if (mapController != null && center != null) {
      double zoomLevel = getZoomLevel(radius);
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(center, zoomLevel),
      );
    }
  }

  double getZoomLevel(double radius) {
    double scale =
        radius / 500; // Adjust the denominator based on map projection
    double zoomLevel =
        16 - log(scale) / log(4); // Adjust 16 based on desired max zoom
    return zoomLevel;
  }

  void getCurrentLocations() async {
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      ref.read(searchLocationControllerProvider).setStartLat(position.latitude);
      ref
          .read(searchLocationControllerProvider)
          .setStartLong(position.longitude);
      ref
          .read(searchLocationControllerProvider)
          .setCurrentLocation(LatLng(position.latitude, position.longitude));
      // Log.d("Current Location Checking");
    });
  }

  void checkDistance() async {
    bool isDistanceCheckActive =
        ref.watch(searchLocationControllerProvider).isDistanceCheckActive;
    bool isEntryMode = ref.watch(searchLocationControllerProvider).isEntryMode;
    if (isDistanceCheckActive) return;

    double? alertRadius =
        ref.watch(searchLocationControllerProvider).alertRadius;
    LatLng? searchLocation =
        ref.watch(searchLocationControllerProvider).pickupGeometry;
    LatLng? currentLocation =
        ref.watch(searchLocationControllerProvider).currentLocation;
    GoogleMapController? mapController =
        ref.watch(searchLocationControllerProvider).googleMapController;

    if (currentLocation != null && searchLocation != null) {
      ref.read(searchLocationControllerProvider).setIsDistanceCheckActive(true);

      // await startBackgroundService();
      double distance = Geolocator.distanceBetween(
          currentLocation.latitude,
          currentLocation.longitude,
          searchLocation.latitude,
          searchLocation.longitude);
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation, zoom: 18.5)));
      bool isWithinRadius = distance <= alertRadius;
      if (isEntryMode) {
        // Trigger entry alarm if within radius and not previously within radius
        if (isWithinRadius) {
          final isAlarmActive =
              ref.read(searchLocationControllerProvider).isAlarmActive;
          if (!isAlarmActive) {
            triggerAlarm(); // Trigger alarm if it's not already active
            _notificationBarService.showNotification(
                context, "Your Entered the location", stopDistanceCheck);

            await notificationService.showPersistentNotification(
                title: "Travel near me", body: "Your Entered the location ");
          }
        }
      } else {
        if (!isWithinRadius) {
          final isAlarmActive =
              ref.read(searchLocationControllerProvider).isAlarmActive;
          if (!isAlarmActive) {
            triggerAlarm(); // Trigger alarm if it's not already active
            _notificationBarService.showNotification(
                context, "Your Exited the location", stopDistanceCheck);
            await notificationService.showPersistentNotification(
                title: "Travel near me", body: "Your Exited the location");
          }
        }
      }
    }

    // Schedule next check after 2 seconds
    _distanceCheckTimer = Timer(const Duration(seconds: 2), () {
      ref
          .read(searchLocationControllerProvider)
          .setIsDistanceCheckActive(false);
      checkDistance();
    });
  }

  void triggerAlarm() {
    ref.read(searchLocationControllerProvider).setIsAlarmActive(true);
    playAlarm();
    Vibration.vibrate();

    Timer.periodic(const Duration(seconds: 5), (timer) {
      bool isAlarmActive =
          ref.read(searchLocationControllerProvider).isAlarmActive;
      if (!isAlarmActive) {
        timer.cancel();
      } else {
        playAlarm();
        Vibration.vibrate();
      }
    });
  }

  void stopAlarm() {
    ref.read(searchLocationControllerProvider).setIsAlarmActive(false);
    player.stop();
    setState(() {
      polylineCoordinates.clear();
      polylines.clear();
      markers.clear();
    });
  }

  Future<void> playAlarm() async {
    try {
      await player.play(AssetSource('sounds/message_nice.mp3'));
    } catch (error) {
      Log.d('Audio play error: $error');
    }
  }

  // Add a function to stop the distance check
  void stopDistanceCheck() {
    _notificationBarService.hideNotification();
    ref.read(searchLocationControllerProvider).setPickupGeometry(null);
    searchPlaceController.clear();
    ref.read(searchLocationControllerProvider).setIsDistanceCheckActive(false);
    player.stop();
    stopAlarm();
    _distanceCheckTimer?.cancel();
    ref.read(searchLocationControllerProvider).setSnackBarVisible(false);
    ref.read(searchLocationControllerProvider).setAlertRadius(50);
    notificationService.stopAlarm();
    Log.d('Distance check stopped');
    _notificationSubscription.cancel();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    GoogleMapController? googleMapController =
        ref.watch(searchLocationControllerProvider).googleMapController;
    googleMapController!.dispose();
    streamSubscription?.cancel();
    _notificationSubscription.cancel();
    searchPlaceController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double alertRadius =
        ref.watch(searchLocationControllerProvider).alertRadius;
    bool isLoading = ref.watch(searchLocationControllerProvider).isLoading;
    bool isEntryMode = ref.watch(searchLocationControllerProvider).isEntryMode;
    bool isBottomSheetShown =
        ref.watch(searchLocationControllerProvider).isBottomSheetShown;

    LatLng? pickUpGeometry =
        ref.watch(searchLocationControllerProvider).pickupGeometry;
    LatLng? currentLocation =
        ref.watch(searchLocationControllerProvider).currentLocation;
    bool isSnackBarVisible =
        ref.watch(searchLocationControllerProvider).isSnackBarVisible ?? false;
    if (currentLocation == null) {
      return const Center(
          child: CircularProgressIndicator()); // Or any fallback UI
    }
    return WillPopScope(
      onWillPop: () async {
        if (isBottomSheetShown) {
          Navigator.pop(context);
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: scaffoldMessengerKey,
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: currentLocation, zoom: 12),
                        mapType: MapType.hybrid,
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        myLocationEnabled: true,
                        markers: <Marker>{
                          if (ref
                                  .read(searchLocationControllerProvider)
                                  .pickupGeometry !=
                              null)
                            Marker(
                              markerId: const MarkerId('pickup'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen),
                              position: pickUpGeometry!,
                            ),
                        },
                        polylines: {
                          Polyline(
                              polylineId: const PolylineId('poly'),
                              points: polylineCoordinates,
                              color: Colors.blue,
                              width: 6)
                        },
                        circles: {
                          if (pickUpGeometry != null)
                            Circle(
                                circleId: const CircleId('origin'),
                                center: pickUpGeometry,
                                radius: alertRadius,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                                fillColor: isEntryMode
                                    ? Colors.blue
                                        .withOpacity(0.2) // Blue for Entry
                                    : Colors.orange.withOpacity(0.2)),
                        },
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                          ref
                              .read(searchLocationControllerProvider)
                              .setGoogleMapController(controller);
                          _getPolyline();
                        }),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const PlaceListUI()));
                      },
                    ),
                  ),
                  if (!isSnackBarVisible)
                    Positioned(
                      left: 0.w,
                      right: 0.w,
                      top: 100.h,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            child: TextFormField(
                              controller: searchPlaceController,
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.start,
                              onChanged: (query) => placesAutoComplete(query),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon:
                                    const Icon(Icons.location_on_outlined),
                                suffixIcon: searchPlaceController.text == ""
                                    ? InkWell(
                                        onTap: () async {
                                          showRadiusSelectedBottomSheet(
                                              context);
                                        },
                                        child: const Icon(
                                            Icons.my_location_outlined),
                                      )
                                    : InkWell(
                                        onTap: () async {
                                          searchPlaceController.clear();
                                          stopDistanceCheck();
                                        },
                                        child: const Icon(Icons.close),
                                      ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 20),
                                hintText: "Alarm Location",
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  Positioned(
                    left: 0.w,
                    right: 0.w,
                    top: 160.h,
                    child: Column(
                      children: [
                        predictionsList.isEmpty ||
                                searchPlaceController.text == ""
                            ? const SizedBox()
                            : Container(
                                height: 300.h,
                                margin: EdgeInsets.symmetric(horizontal: 16.w),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r)),
                                child: isLoading
                                    ? const Center(
                                        child:
                                            SpinKitHourGlass(color: Colors.red))
                                    : predictionsList.isEmpty
                                        ? const Center(child: Text('No Place'))
                                        : ListView.builder(
                                            itemCount: predictionsList.length,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            itemBuilder: (_, i) {
                                              return AddressFieldContainer(
                                                  onTap: () async {
                                                    placeIdToGeocode(
                                                        predictionsList[i]
                                                                .placeId ??
                                                            '');
                                                    setPickupAddress(
                                                        predictionsList[i]
                                                                .description ??
                                                            '');
                                                    setState(() {
                                                      searchPlaceController
                                                              .text =
                                                          predictionsList[i]
                                                                  .description ??
                                                              '';
                                                      String shortDescription =
                                                          searchPlaceController
                                                              .text
                                                              .split(',')
                                                              .first
                                                              .trim();
                                                      alarmNameController.text =
                                                          shortDescription;
                                                      predictionsList.clear();
                                                      ref
                                                          .read(
                                                              searchLocationControllerProvider)
                                                          .setLoading(false);
                                                    });

                                                    // Unfocused the search field
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                  predictions:
                                                      predictionsList[i]);
                                            }),
                              )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getPolyline() async {
    LatLng? pickUpGeometry =
        ref.watch(searchLocationControllerProvider).pickupGeometry;
    LatLng? currentLocation =
        ref.watch(searchLocationControllerProvider).currentLocation;
    if (currentLocation == null || pickUpGeometry == null) {
      Log.d("Current location or pick up geometry is null");
      return;
    }
    polylineCoordinates.clear();
    polylines.clear();

    /// add origin marker origin marker
    _addMarker(
      LatLng(currentLocation.latitude, currentLocation.longitude),
      "origin",
      BitmapDescriptor.defaultMarker,
    );

    // Add destination marker
    _addMarker(
      LatLng(pickUpGeometry.latitude, pickUpGeometry.longitude),
      "destination",
      BitmapDescriptor.defaultMarkerWithHue(90),
    );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        ApiKey.placeApiKey,
        PointLatLng(currentLocation.latitude, currentLocation.longitude),
        PointLatLng(pickUpGeometry.latitude, pickUpGeometry.longitude),
        travelMode: TravelMode.walking);
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      Log.d(result.errorMessage ?? "Error fetching polyline");
    }

    _addPolyLine(polylineCoordinates);
    setState(() {});
  }

  // This method will add markers to the map based on the LatLng position
  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        points: polylineCoordinates,
        width: 4,
        color: Colors.blue);

    polylines[id] = polyline;
    setState(() {});
  }
}
