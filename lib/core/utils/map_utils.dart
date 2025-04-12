import 'package:share_loc/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;

osm.MapController createMapController() {
  return osm.MapController.withUserPosition(
    trackUserLocation: const osm.UserTrackingOption(
      enableTracking: true,
    ),
    useExternalTracking: true,
  );
}

osm.OSMOption getOSMOptions() {
  return osm.OSMOption(
    userTrackingOption: const osm.UserTrackingOption(
      enableTracking: true,
    ),
    zoomOption: const osm.ZoomOption(
      initZoom: 12,
      minZoomLevel: 3,
    ),
    userLocationMarker: osm.UserLocationMaker(
      personMarker: Constants.myMarker,
      directionArrowMarker: const osm.MarkerIcon(
        icon: Icon(
          Icons.double_arrow,
          size: 48,
        ),
      ),
    ),
    roadConfiguration: const osm.RoadOption(
      roadColor: Colors.yellowAccent,
    ),
  );
}
