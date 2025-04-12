import 'dart:convert';

import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:share_loc/core/utils/typedef.dart';
import 'package:share_loc/features/auth/domain/entities/user.dart';

class LocalUserModel extends LocalUser {
  const LocalUserModel({
    required super.uid,
    required super.email,
    required super.points,
    required super.fullName,
    super.groupIds,
    super.following,
    super.followers,
    super.profilePic,
    super.bio,
    super.currentLocation,
    super.currentCircle,
    super.geoPoint,
    super.locationSyncAt,
  });

  const LocalUserModel.empty()
      : this(
          uid: '',
          email: '',
          points: 0,
          fullName: '',
          currentLocation: '',
          currentCircle: '',
          geoPoint: null,
          locationSyncAt: '',
        );

  LocalUserModel.fromMap(DataMap map)
      : super(
          uid: map['uid'] as String,
          email: map['email'] as String,
          points: (map['points'] as num).toInt(),
          fullName: map['fullName'] as String,
          profilePic: map['profilePic'] as String?,
          bio: map['bio'] as String?,
          groupIds: (map['groupIds'] as List?)?.cast<String>() ?? const [],
          following: (map['following'] as List?)?.cast<String>() ?? const [],
          followers: (map['followers'] as List?)?.cast<String>() ?? const [],
          currentLocation: map['currentLocation'] as String? ?? '',
          currentCircle: map['currentCircle'] as String? ?? '',
          geoPoint: map['geoPoint'] != null
              ? GeoPoint(
                  latitude: (map['geoPoint']['lat'] ?? 0.0) as double,
                  longitude: (map['geoPoint']['lon'] ?? 0.0) as double,
                )
              : null,
          locationSyncAt: map['lastCheckedInAt'] as String? ?? '',
        );

  LocalUserModel copyWith({
    String? uid,
    String? email,
    String? profilePic,
    String? bio,
    int? points,
    String? fullName,
    List<String>? groupIds,
    List<String>? following,
    List<String>? followers,
    String? currentLocation,
    String? currentCircle,
    GeoPoint? geoPoint,
    String? locationSyncAt,
  }) {
    return LocalUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      points: points ?? this.points,
      fullName: fullName ?? this.fullName,
      profilePic: profilePic ?? this.profilePic,
      bio: bio ?? this.bio,
      groupIds: groupIds ?? this.groupIds,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      currentLocation: currentLocation ?? this.currentLocation,
      currentCircle: currentCircle ?? this.currentCircle,
      geoPoint: geoPoint ?? this.geoPoint,
      locationSyncAt: locationSyncAt ?? this.locationSyncAt,
    );
  }

  DataMap toMap() {
    return {
      'uid': uid,
      'email': email,
      'profilePic': profilePic,
      'bio': bio,
      'points': points,
      'fullName': fullName,
      'currentLocation': currentLocation,
      'currentCircle': currentCircle,
      'locationSyncAt': locationSyncAt,
      'geoPoint': geoPoint != null
          ? {
              'lat': geoPoint!.latitude,
              'lon': geoPoint!.longitude,
            }
          : null,
      'groupIds': groupIds,
      'following': following,
      'followers': followers,
    };
  }

  String toJson() => json.encode(toMap());
}
