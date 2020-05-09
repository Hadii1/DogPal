import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/models/adopt_post.dart';
import 'package:dog_pal/models/dog.dart';
import 'package:dog_pal/models/lost_post.dart';
import 'package:dog_pal/models/mate_post.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/dog_util.dart';
import 'dart:math' as _Math;

Future<void> createMateData() async {
  Firestore _db = Firestore.instance;
  DocumentReference reference =
      _db.collection(FirestoreConsts.MATE_DOGS).document();
  MatePost matePost = MatePost(
    locationDisplay: 'a',
    id: reference.documentID,
    description:
        ''' inwrd qualms, when he reached the Father Superior's with Ivan: he felt ashamed of havin lost his temper. He felt that he ought to have disdaimed that despicable wretch, Fyodor Pavlovitch, too much to have been upset by him in Father Zossima's cell, and so to have forgotten himself. "Teh monks were not to blame, in any case," he reflceted, on the steps. "And if they're decent people here (and the Father Superior, I understand, is a nobleman) why not be friendly and courteous withthem? I won't argue, I'll fall in with everything, I'll win them by politness, and show them that I've nothing to do with that Aesop, thta buffoon, that Pierrot, and have merely been takken in over this affair, just as they have.
  ''',
    city: 'Kfar Dounine',
    town: 'asf',
    district: 'Nabatiyeh Governorate',
    dog: MateDog(
      pedigree: _Math.Random().nextInt(2) == 0,
      age: '',
      breed: _getBreed(),
      coatColors: _getColors(),
      dogName: _getName(),
      gender: _getGender(),
      imagesUrls: _getImages(),
      size: 'Toy',
      vaccinated: _Math.Random().nextInt(2) == 0,
      owner: User(
        uid: 's',
        email: 'Hadi.hammoud@live.com',
        username: 'God',
        phoneNumber: '03414543',
        photo: _getImages()[_Math.Random().nextInt(
          _getImages().length,
        )],
      ),
    ),
    dateAdded:
        Timestamp.fromDate(_dates[_Math.Random().nextInt(_dates.length)]),
  );
  reference.setData(MatePost.toDocument(matePost));
}

Future<void> createLostData(String uid) async {
  Firestore db = Firestore.instance;
  DocumentReference reference = db.collection('LostDogs').document();
  LostPost post = LostPost(
    locationDisplay: 'Haret Hreik, Lebanon',
    dog: Dog(
      imagesUrls: [
        'https://www.google.com/search?q=dog+images&rlz=1C5CHFA_enLB879LB879&sxsrf=ALeKk00zu_RL5g80Uw-ZgQaYtkwfvuorhQ:1586004505831&tbm=isch&source=iu&ictx=1&fir=AoD4xXlxdm30WM%253A%252COBh1eXSFpXCdlM%252C_&vet=1&usg=AI4_-kQHH5B1_eyL5-aevfZ1z2lBNofzdQ&sa=X&ved=2ahUKEwjnpbqZ587oAhWOAWMBHWnEB0MQ9QEwAHoECAoQMA#imgrc=AoD4xXlxdm30WM:'
      ],
      breed: _getBreed(),
      gender: _getGender(),
      dogName: _getName(),
      coatColors: _getColors(),
      owner: User(
        uid: uid,
        email: 'Hadi.hammoud@live.com',
        username: 'God',
        phoneNumber: '03414543',
        photo: null,
      ),
    ),
    id: reference.documentID,
    description: '',
    town: 'asf',
    city: 'Baabda',
    district: 'saf',
    dateAdded:
        Timestamp.fromDate(_dates[_Math.Random().nextInt(_dates.length)]),
  );

  reference.setData(LostPost.toDocument(post));

  print('added');
}

Future<void> createAdoptData() async {
  Firestore db = Firestore.instance;

  DocumentReference reference = db.collection('Adoption Dogs').document();

  AdoptPost adoptPost = AdoptPost(
    locationDisplay: 's',
    city: 'San Francisco',
    dateAdded:
        Timestamp.fromDate(_dates[_Math.Random().nextInt(_dates.length)]),
    description: 'No description',
    district: 'San Francisco',
    town: 'asfd',
    id: reference.documentID,
    dog: AdoptionDog(
      age: '',
      pedigree: _Math.Random().nextInt(2) == 0,
      appartmentFriendly: _Math.Random().nextInt(2) == 0,
      barkTendencies: 'Low',
      breed: _getBreed(),
      coatColors: _getColors(),
      dogName: _getName(),
      energyLevel: 'Moderate',
      gender: _getGender(),
      imagesUrls: _getImages(),
      petFriendly: true,
      size: 'Toy',
      vaccinated: false,
      sheddingLevel: 'Low',
      trainingLevel: 'Basic',
      owner: User(
        uid: 'asdsafsfas',
        email: 'Hadi.hammoud@live.com',
        username: 'God',
        phoneNumber: '',
        photo: '',
      ),
    ),
  );

  reference.setData(AdoptPost.toDocument(adoptPost));

  print('added');
}

String _getName() {
  var a = _Math.Random();

  String name = '';

  for (int i = 0; i < 5; i++) {
    String d = _ALPHABETS[a.nextInt(26)];
    name = '$name$d';
  }

  return name;
}

List _getColors() {
  List list = [];
  for (int i = 0; i < 3; i++) {
    list.add(
        DogUtil.DOG_COLORS[_Math.Random().nextInt(DogUtil.DOG_COLORS.length)]);
  }

  return list;
}

String _getGender() {
  if (_Math.Random().nextInt(2) == 0) {
    return 'Female';
  }
  return 'Male';
}

List _getImages() {
  int rnd = _Math.Random().nextInt(3);

  return [_IMAGES[rnd]];
}

String _getBreed() {
  return DogUtil.DOG_BREEDS[_Math.Random().nextInt(DogUtil.DOG_BREEDS.length)];
}

const List<String> _ALPHABETS = [
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z'
];

// const List _CITIES = ['Beirut', 'Berlin', 'Mountain View', 'Kfar Dounine'];

const List _IMAGES = [
  'https://firebasestorage.googleapis.com/v0/b/dog-pal-e813b.appspot.com/o/Lost%20Dogs%2Fphoto-1514730206490-dcb94a491ded.jpeg?alt=media&token=b59224f0-afd7-47fb-93c5-920aa78d5b7b',
  'https://firebasestorage.googleapis.com/v0/b/dog-pal-e813b.appspot.com/o/Lost%20Dogs%2Fsmartest-dog-breeds-1553287693.jpg?alt=media&token=6d7ea6a8-8c56-49f8-a0dc-ff5d482ab07a',
  'https://firebasestorage.googleapis.com/v0/b/dog-pal-e813b.appspot.com/o/Lost%20Dogs%2Ffriendliest-dog-breeds-golden-1578596627.jpg?alt=media&token=f910679c-8663-489c-8a27-a1d7e303cec7',
];

List<DateTime> _dates = [
  DateTime(2019, 3, 2),
  DateTime(2020, 3, 1),
  DateTime(2020, 2, 1),
  DateTime(2017, 4, 4),
  DateTime(2011, 5, 1),
  DateTime(2019, 11, 3),
  DateTime(2014, 12, 23),
  DateTime(2018, 2, 11),
  DateTime(2018, 2, 17),
  DateTime(2018, 4, 24),
  DateTime(2014, 5, 14),
  DateTime(2018, 6, 11),
  DateTime(2011, 7, 6),
  DateTime(2018, 9, 9),
  DateTime(2020, 1, 30),
  DateTime(2020, 2, 8),
  DateTime(2015, 6, 4),
  DateTime(2019, 5, 15)
];
