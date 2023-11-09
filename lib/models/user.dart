import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  final String uid;
  final String email;
  final String passwordcheck;
  final String photoUrl;
  final String username;
  final String password;
  final List followers;
  final List following;
  final List blocking;
  final List blocked;

  const User(
      {required this.uid,
      required this.username,
      required this.email,
      required this.passwordcheck,
      required this.photoUrl,
      required this.password,
      required this.followers,
      required this.following,
      required this.blocking,
      required this.blocked});

  Map<String, dynamic> toJason() => {
        'uid': uid,
        'username': username,
        'passwordcheck': passwordcheck,
        'email': email,
        'password': password,
        'followers': followers,
        'following': following,
        'photoUrl': photoUrl,
        'blocking': blocking,
        'blocked': blocked,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      uid: snapshot['uid'],
      username: snapshot['username'],
      email: snapshot['email'],
      photoUrl: snapshot['photoUrl'],
      password: snapshot['password'],
      passwordcheck: snapshot['passwordcheck'],
      following: snapshot['following'],
      followers: snapshot['followers'],
      blocking: snapshot['blocking'],
      blocked: snapshot['blocked'],
    );
  }
}
