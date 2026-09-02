// ignore_for_file: prefer_collection_literals
import 'dart:math';

import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';
import 'package:mobile_in_out/core/utils/models/schedule_model.dart';
import 'package:mobile_in_out/feature/history/model/group_shift_schedule_response.dart';
import 'package:mobile_in_out/feature/maps/provider/map_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

@RoutePage()
class MapPage extends StatefulWidget {
  final Position currentPosition;
  final String detailAddress;
  // final List<ScheduleModel> workLocation;
  final List<GroupShiftScheduleResponse> workLocation;
  const MapPage({
    super.key,
    required this.currentPosition,
    required this.detailAddress,
    required this.workLocation,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapProvider mapProvider;

  @override
  void initState() {
    mapProvider = context.read<MapProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: Stack(children: [_buildGoogleMap(), _buildPositionedBottom()]),
    );
  }

  GoogleMap _buildGoogleMap() {
    return GoogleMap(
      zoomControlsEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        mapProvider.setMapController(controller);
        mapProvider.setCompleter(controller);
      },
      markers: Set()
        ..add(
          Marker(
            markerId: MarkerId(Random().nextInt(100).toString()),
            position: LatLng(
              widget.currentPosition.latitude,
              widget.currentPosition.longitude,
            ),
            draggable: false,
            onDrag: (LatLng position) {
              LogHelper.logDebug('Position: $position ✅✅✅');
            },
          ),
        )
        ..addAll(
          widget.workLocation.map((location) {
            return Marker(
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
              markerId: MarkerId(location.locationId.toString()),
              position: LatLng(
                location.latitude ?? 0.0,
                location.longitude ?? 0.0,
              ),
              infoWindow: InfoWindow(
                title: location.locationName,
                snippet: location.locationName,
              ),
            );
          }),
        ),
      circles: Set()
        ..add(
          Circle(
            circleId: CircleId(Random().nextInt(100).toString()),
            center: LatLng(
              widget.workLocation.first.latitude ?? 0.0,
              widget.workLocation.first.longitude ?? 0.0,
            ),
            radius: widget.workLocation.first.radius?.toDouble() ?? 200,
            fillColor: Colors.blue.withOpacity(.2),
            strokeColor: Colors.blue,
            strokeWidth: 1,
          ),
        ),
      initialCameraPosition: CameraPosition(
        target: LatLng(
          widget.currentPosition.latitude,
          widget.currentPosition.longitude,
        ),
        zoom: 15,
      ),
    );
  }

  Positioned _buildPositionedBottom() {
    return Positioned(bottom: 0, left: 0, right: 0, child: _buildContainer());
  }

  Container _buildContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 5),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLocationInfo('Latitude', widget.currentPosition.latitude),
              _buildLocationInfo('Longitude', widget.currentPosition.longitude),
            ],
          ),

          const SizedBox(height: 5),

          const Divider(),

          const SizedBox(height: 5),

          const Text(
            'Lokasi Anda',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 5),

          Text(widget.detailAddress, style: const TextStyle(fontSize: 12)),

          const SizedBox(height: 5),

          // Add instructions on how to move the marker
          const Divider(),
          const Text(
            "Perhatikan posisi anda!",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: AppColors.redColors,
            ),
          ),

          const SizedBox(height: 5),

          // Calculate distance between two points
          const Divider(),
          const Text(
            "Distance to Registered Location",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 5),

          ...widget.workLocation.map((e) {
            final distanceInMeters = Geolocator.distanceBetween(
              widget.currentPosition.latitude,
              widget.currentPosition.longitude,
              e.latitude ?? 0.0,
              e.longitude ?? 0.0,
            );

            final distanceInKm = distanceInMeters / 1000;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Colors.grey),
                      Text(
                        e.locationName?.toUpperCase() ?? 'Unknown Location',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Divider(color: Colors.grey),
                      Text(
                        '${distanceInKm.toStringAsFixed(2)} KM',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),

          // ...widget.workLocation.map((e) {
          //   final distanceInMeters = Geolocator.distanceBetween(
          //     widget.currentPosition.latitude,
          //     widget.currentPosition.longitude,
          //    -8.589072497799867, 116.12067975103854
          //   );

          //   final distanceInKm = distanceInMeters / 1000;

          //   return Text(
          //     '${e.locationName}: ${distanceInKm.toStringAsFixed(2)} KM',
          //     style: const TextStyle(
          //       fontSize: 12,
          //     ),
          //   );
          // }).toList(),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text('$value', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
