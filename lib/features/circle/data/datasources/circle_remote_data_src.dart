import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_loc/core/common/errors/exceptions.dart';
import 'package:share_loc/core/enums/update_creator.dart';
import 'package:share_loc/core/utils/constants.dart';
import 'package:share_loc/features/circle/data/models/circle_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

abstract class CircleRemoteDataSrc {
  const CircleRemoteDataSrc();

  Future<LocalCircleModel> createCircle({
    required String name,
    required String phoneNumber,
  });

  Future<void> updateCreatorRole({
    required String circleId,
    required Role role,
  });

  Future<void> joinCircle(String invitationCode);
}

class CircleRemoteDataSrcImpl implements CircleRemoteDataSrc {
  CircleRemoteDataSrcImpl({
    required FirebaseFirestore cloudStoreClient,
    required FirebaseStorage dbClient,
  })  : _cloudStoreClient = cloudStoreClient,
        _dbClient = dbClient;

  final FirebaseFirestore _cloudStoreClient;
  final FirebaseStorage _dbClient;

  final _uuid = const Uuid();

  @override
  Future<LocalCircleModel> createCircle({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw const ServerException(
          message: 'User not logged in',
          statusCode: '401',
        );
      }

      final docRef = _cloudStoreClient.collection(Constants.dbCircle).doc();

      final invitationCode = _uuid.v4().substring(0, 4).toUpperCase();

      final circle = LocalCircleModel(
        circleName: name,
        circleId: docRef.id,
        creatorId: user.uid,
        creatorRole: 'admin',
        invitationCode: invitationCode,
        members: [user.uid],
      );

      await docRef.set(circle.toMap());

      await _cloudStoreClient
          .collection(Constants.dbUsers)
          .doc(user.uid)
          .update({'currentCircle': docRef});

      return circle;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Future<void> updateCreatorRole({
    required String circleId,
    required Role role,
  }) async {
    try {
      // Convert
      final roleString = role.toString().split('.').last;

      // find circle
      final docRef =
          _cloudStoreClient.collection(Constants.dbCircle).doc(circleId);

      await docRef.update({
        'creatorRole': roleString,
      });
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }

  @override
  Future<void> joinCircle(String invitationCode) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw const ServerException(
          message: 'User not logged in',
          statusCode: '401',
        );
      }

      final query = await _cloudStoreClient
          .collection(Constants.dbCircle)
          .where('invitationCode', isEqualTo: invitationCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw const ServerException(
          message: 'Invalid invitation code',
          statusCode: '404',
        );
      }

      final doc = query.docs.first.reference;
      final circleId = doc.id;
      //! Check if circle already joined
      // final data = query.docs.first.data();
      // final members = List<String>.from(data['members'] as List? ?? []);

      // if (members.contains(user.uid)) {
      //   throw const ServerException(
      //     message: 'You have already joined this circle',
      //     statusCode: '409',
      //   );
      // }

      await doc.update({
        'members': FieldValue.arrayUnion([user.uid]),
      });

      await _cloudStoreClient
          .collection(Constants.dbUsers)
          .doc(user.uid)
          .update({'currentCircle': circleId});
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '500');
    }
  }
}
