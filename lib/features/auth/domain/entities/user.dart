import 'package:equatable/equatable.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class LocalUser extends Equatable {
  const LocalUser({
    required this.uid,
    required this.email,
    required this.points,
    required this.fullName,
    this.currentLocation,
    this.currentCircle,
    this.geoPoint,
    this.locationSyncAt,
    this.groupIds = const [],
    this.following = const [],
    this.followers = const [],
    this.profilePic,
    this.bio,
  });

  const LocalUser.empty()
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

  final String uid;
  final String email;
  final String? profilePic;
  final String? bio;
  final int points;
  final String fullName;
  final String? currentLocation;
  final String? currentCircle;
  final GeoPoint? geoPoint;
  final String? locationSyncAt;
  final List<String> groupIds;
  final List<String> following;
  final List<String> followers;

  @override
  List<Object?> get props => [uid, email];

  @override
  String toString() {
    return 'LocalUser(uid: $uid, email: $email, '
        'fullName: $fullName, bio: $bio, points: $points)';
  }
}
