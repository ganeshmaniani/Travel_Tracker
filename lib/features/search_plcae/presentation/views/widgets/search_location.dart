import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_near_me/core/app_key.dart';
import 'package:travel_near_me/features/search_plcae/presentation/provider/search_location_provider.dart';

import '../../../../../config/app_theme/dimensions.dart';
import '../../../data/model/auto_complete_prediction_model.dart';
import '../../../data/model/place_to_geocode_model.dart';
import '../../../domain/entities/place_entities.dart';
import '../../../domain/entities/place_to_geocode_entities.dart';

class SearchLocationScreen extends ConsumerStatefulWidget {
  final String label;
  final TextEditingController controller;

  const SearchLocationScreen(
      {super.key, required this.label, required this.controller});

  @override
  ConsumerState<SearchLocationScreen> createState() =>
      _SearchLocationScreenConsumerState();
}

class _SearchLocationScreenConsumerState
    extends ConsumerState<SearchLocationScreen> {
  bool isLoading = false;

  List<Predictions> predictionsList = [];
  List<GeocodeList> geocodeList = [];

  var latitude = '';
  var longitude = '';
  late StreamSubscription<Position> streamSubscription;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    placesAutoComplete(widget.controller.text);
  }

  /// Search the Place
  void placesAutoComplete(String query) async {
    setState(() => isLoading = true);
    ref
        .read(searchLocationProvider.notifier)
        .autoCompletePlaceList(
          PlaceEntities(query: query, key: ApiKey.placeApiKey),
        )
        .then((res) => res.fold(
            (l) => {
                  predictionsList = [],
                  setState(() => isLoading = false),
                },
            (r) => {
                  predictionsList = r.predictions ?? [],
                  setState(() => isLoading = false),
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

  void getLatLong(List<GeocodeList> geocode) {
    Geometry val = geocode[0].geometry!;

    // if (widget.label == 'Alarm location') {
    // setState(() {
    //   ref
    //       .read(searchLocationControllerProvider)
    //       .setPickupGeometry(LatLng(val.location!.lat!, val.location!.lng!));
    //   Navigator.pop(context);
    // });
    // }
    if (widget.label == 'Alarm location?') {
      setState(() {
        ref
            .read(searchLocationControllerProvider)
            .setDropOffGeometry(LatLng(val.location!.lat!, val.location!.lng!));
        Navigator.pop(context);
      });

      debugPrint("${val.location!.lat!}, ${val.location!.lng!}");
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
            Navigator.pop(context),
            setPickAddressFromLocation(position.latitude, position.longitude),
            pickupGeometry =
                ref.watch(searchLocationControllerProvider).pickupGeometry,
            log("Pick$pickupGeometry")
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

  @override
  void dispose() {
    // Cancel the stream subscription to prevent memory leaks
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 6),
            color:
                widget.label == "Alarm location?" ? Colors.white : Colors.red,
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_sharp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextFormField(
                    autofocus: true,
                    controller: widget.controller,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.start,
                    onChanged: (query) => placesAutoComplete(query),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.location_on_outlined),
                      suffixIcon: InkWell(
                        onTap: () => getCurrentLocation(),
                        child: Icon(Icons.my_location_outlined),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50).w,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 20),
                      hintText: widget.label,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: SpinKitHourGlass(color: Colors.red))
                : predictionsList.isEmpty
                    ? const Center(child: Text('No Place'))
                    : ListView.builder(
                        itemCount: predictionsList.length,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemBuilder: (_, i) {
                          return predictionsPlaceList(
                            onTap: () {
                              placeIdToGeocode(
                                  predictionsList[i].placeId ?? '');
                              setPickupAddress(
                                  predictionsList[i].description ?? '');
                            },
                            predictions: predictionsList[i],
                          );
                        }),
          ),
        ],
      ),
    );
  }

  void setPickupAddress(String query) async {
    // if (widget.label == 'Choose start location') {
    //   ref.read(searchLocationControllerProvider).setPickupAddress(query);
    // }
    if (widget.label == 'Alarm location?') {
      ref.read(searchLocationControllerProvider).setDropOffAddress(query);
    }
  }

  Widget predictionsPlaceList(
      {required VoidCallback onTap, required Predictions predictions}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16).w,
        child: Container(
          padding: const EdgeInsets.all(16.0).w,
          decoration: BoxDecoration(
            borderRadius: Dimensions.kBorderRadiusAllSmall,
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: Dimensions.iconSizeSmall,
              ),
              Dimensions.kHorizontalSpaceMedium,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      predictions.structuredFormatting!.mainText ?? '',
                    ),
                    Text(
                      predictions.description ?? '',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
