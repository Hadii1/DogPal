import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:dog_pal/models/dog.dart';
import 'package:dog_pal/models/lost_post.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/pagination_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dog_pal/models/user.dart';

/*/*/* 


      
      We first search the town, get it's documents,
      if they're too few add them to a list and start another
      query based on city, if not enough we do the same based 
      on district and then merge. We keep last document ref for 
      pagination and load more data each time the user scrolls ~60%
      of screen height.
      This method will yield duplicate data and unnecessary reads
      because the city query will probably contain the town documents
      once again, same for district query which will contain the
      town and city documents too. This can be solved using lexigographic
      comparison of strings which I might do later depending on the app success
      but at the moment this seems premature for an app that yet has no users base.
  

    #The document limit we use for queries is 40

*/*/*/

MockFirestoreInstance _instance;

LostPost _post = LostPost(
  town: '',
  city: '',
  district: '',
  locationDisplay: '',
  type: '',
  dateAdded: Timestamp.fromDate(DateTime.now()),
  description: '',
  id: '',
  dog: Dog(
    breed: '',
    coatColors: [],
    dogName: '',
    gender: '',
    imagesUrls: [],
    owner: User(
      username: '',
      email: '',
      photo: '',
      uid: '',
      dataJoined: DateTime.now().toString(),
      favAdoptionPosts: [],
      favMatingPosts: [],
      firstName: '',
      phoneNumber: '',
    ),
  ),
);

Future<void> _createMockData({
  @required int townPosts,
  @required int cityPosts,
  @required int districtPosts,
}) async {
  for (int i = 0; i < townPosts; i++) {
    _post
      ..town = 't'
      ..city = ''
      ..district = '';
    await _instance.collection('LostDogs').add(LostPost.toDocument(_post));
  }

  for (int i = 0; i < cityPosts; i++) {
    _post
      ..town = ''
      ..city = 'c'
      ..district = '';

    await _instance.collection('LostDogs').add(LostPost.toDocument(_post));
  }
  for (int i = 0; i < districtPosts; i++) {
    _post
      ..town = ''
      ..city = ''
      ..district = 'd';

    await _instance.collection('LostDogs').add(LostPost.toDocument(_post));
  }
}

void main() {
  //The class we're testing
  PaginationUtil paginationUtil;

  setUp(() {
    _instance = MockFirestoreInstance();

    paginationUtil = PaginationUtil();

    // Init queries, such quesries are initialized in the repositaries.
    // The document limit is 40
    paginationUtil.firstQuery = _instance
        .collection(FirestoreConsts.LOST_DOGS)
        .where(PostsConsts.TOWN, isEqualTo: 't')
        .orderBy(PostsConsts.DATE_ADDED, descending: true);

    paginationUtil.secondQuery = _instance
        .collection(FirestoreConsts.LOST_DOGS)
        .where(PostsConsts.CITY, isEqualTo: 'c')
        .orderBy(PostsConsts.DATE_ADDED, descending: true);

    paginationUtil.thirdQuery = _instance
        .collection(FirestoreConsts.LOST_DOGS)
        .where(PostsConsts.DISTRICT, isEqualTo: 'd')
        .orderBy(PostsConsts.DATE_ADDED, descending: true);
  });

  group('Initial Post fetching', () {
    test('remove duplicate extension removes the right docs', () async {
      DocumentReference ref = _instance.collection('LostDogs').document();
      LostPost post = _post;
      post
        ..town = 't'
        ..city = 'c'
        ..district = 'd';

      await ref.setData(LostPost.toDocument(post));

      List<DocumentSnapshot> list = await paginationUtil.getDogs();

      expect(
        list.length,
        1,
        reason:
            'The three queries will yeild the same post resulting in 3 documents which are filtered to one use the deDup extention',
      );
      expect(paginationUtil.activeQuery, isNull);
      expect(paginationUtil.noMoreDocuments, true);
    });

    test('No enough town posts', () async {
      await _createMockData(townPosts: 30, cityPosts: 60, districtPosts: 0);

      List<DocumentSnapshot> docs = await paginationUtil.getDogs();

      expect(paginationUtil.activeQuery, paginationUtil.secondQuery);
      expect(paginationUtil.noMoreDocuments, false);

      expect(docs.length, 70);

      expect(
          docs
              .where((doc) {
                return LostPost.fromDocument(doc.data).town == 't';
              })
              .toList()
              .length,
          30);

      expect(
          docs
              .where((doc) {
                return LostPost.fromDocument(doc.data).city == 'c';
              })
              .toList()
              .length,
          40);
    });

    test('No enough town and city posts', () async {
      await _createMockData(townPosts: 20, cityPosts: 30, districtPosts: 60);

      List<DocumentSnapshot> docs = await paginationUtil.getDogs();

      expect(docs.length, 90);
      expect(paginationUtil.activeQuery, paginationUtil.thirdQuery);
      expect(paginationUtil.noMoreDocuments, false);

      expect(
          docs
              .where((doc) {
                return LostPost.fromDocument(doc.data).town == 't';
              })
              .toList()
              .length,
          20);

      expect(
          docs
              .where((doc) {
                return LostPost.fromDocument(doc.data).city == 'c';
              })
              .toList()
              .length,
          30);

      expect(
          docs
              .where((doc) {
                return LostPost.fromDocument(doc.data).district == 'd';
              })
              .toList()
              .length,
          40);
    });

    test('No enough town,city and district posts', () async {
      await _createMockData(townPosts: 20, cityPosts: 20, districtPosts: 20);

      List<DocumentSnapshot> docs = await paginationUtil.getDogs();

      expect(docs.length, 60);
      expect(paginationUtil.noMoreDocuments, true);
      expect(paginationUtil.activeQuery, isNull);

      expect(
        docs
            .where((doc) {
              return LostPost.fromDocument(doc.data).town == 't';
            })
            .toList()
            .length,
        20,
      );

      expect(
        docs
            .where((doc) {
              return LostPost.fromDocument(doc.data).city == 'c';
            })
            .toList()
            .length,
        20,
      );

      expect(
        docs
            .where((doc) {
              return LostPost.fromDocument(doc.data).district == 'd';
            })
            .toList()
            .length,
        20,
      );
    });

    test('Enough town posts are present', () async {
      await _createMockData(townPosts: 100, cityPosts: 10, districtPosts: 30);

      List<DocumentSnapshot> docs = await paginationUtil.getDogs();

      expect(docs.length, 40);
      expect(paginationUtil.activeQuery, paginationUtil.firstQuery);
      expect(paginationUtil.noMoreDocuments, false);

      expect(
          docs
              .where((doc) {
                return LostPost.fromDocument(doc.data).town == 't';
              })
              .toList()
              .length,
          40);
    });

    test('Last Doucment is is null if no more docs', () async {
      await _createMockData(townPosts: 20, cityPosts: 0, districtPosts: 0);

      List<DocumentSnapshot> docs = await paginationUtil.getDogs();

      expect(docs.length, 20);
      expect(paginationUtil.noMoreDocuments, true);
      expect(paginationUtil.activeQuery, isNull);
      expect(paginationUtil.lastDocument, isNull);
    });

    test('Last Doucment is is saved ', () async {
      await _createMockData(townPosts: 60, cityPosts: 50, districtPosts: 30);

      List<DocumentSnapshot> docs = await paginationUtil.getDogs();

      expect(docs.length, 40);
      expect(paginationUtil.noMoreDocuments, false);
      expect(paginationUtil.activeQuery, paginationUtil.firstQuery);
      expect(paginationUtil.lastDocument.documentID, docs.last.documentID);
    });
  });

  group('Loading more data', () {
    test(
      'loads more from town query',
      () async {
        await _createMockData(townPosts: 100, cityPosts: 0, districtPosts: 0);

        //initial fetching of posts
        List<DocumentSnapshot> docs = await paginationUtil.getDogs();

        expect(docs, hasLength(40));
        expect(docs.last.documentID, paginationUtil.lastDocument.documentID);
        expect(paginationUtil.activeQuery, paginationUtil.firstQuery);
        expect(paginationUtil.lastDocument, isNotNull);

        //Loading more as user scrolls
        await paginationUtil.loadMoreData();
        expect(
          paginationUtil.allDocs.length,
          80,
          reason: 'initial 40, and another 40',
        );

        expect(paginationUtil.activeQuery, paginationUtil.firstQuery);

        //loads again
        await paginationUtil.loadMoreData();
        expect(paginationUtil.allDocs.length, 100);
        expect(paginationUtil.activeQuery, isNull);
        expect(paginationUtil.noMoreDocuments, true);
      },
    );

    test('loads more from city query', () async {
      await _createMockData(townPosts: 50, cityPosts: 100, districtPosts: 0);

      await paginationUtil.getDogs();

      expect(paginationUtil.allDocs.length, 40);
      expect(paginationUtil.activeQuery, paginationUtil.firstQuery);

      await paginationUtil.loadMoreData();
      expect(
        paginationUtil.allDocs.length,
        90,
        reason:
            'initially 40, we get 10 from first query, then get 40 from city query',
      );
      expect(paginationUtil.activeQuery, paginationUtil.secondQuery);
      expect(
        paginationUtil.allDocs.where((doc) {
          return LostPost.fromDocument(doc.data).city == 'c';
        }),
        hasLength(40),
      );

      expect(
        paginationUtil.allDocs.where((doc) {
          return LostPost.fromDocument(doc.data).town == 't';
        }),
        hasLength(50),
      );
    });

    test('loads more from district query', () async {
      await _createMockData(townPosts: 20, cityPosts: 20, districtPosts: 100);
      await paginationUtil.getDogs();

      expect(paginationUtil.allDocs.length, 80); //20t,20c//40d

      expect(paginationUtil.activeQuery, paginationUtil.thirdQuery);

      await paginationUtil.loadMoreData();
      expect(paginationUtil.allDocs.length, 120);

      await paginationUtil.loadMoreData();
      expect(paginationUtil.allDocs.length, 140);
      expect(paginationUtil.noMoreDocuments, true);
      expect(paginationUtil.activeQuery, isNull);
    });

    test('load more data does nothing when no more docs exist', () async {
      await _createMockData(townPosts: 10, cityPosts: 10, districtPosts: 10);
      await paginationUtil.getDogs();
      expect(paginationUtil.allDocs, hasLength(30));
      expect(paginationUtil.activeQuery, isNull);
      expect(paginationUtil.noMoreDocuments, true);

      await paginationUtil.loadMoreData();
      expect(paginationUtil.allDocs, hasLength(30));
    });
  });
}
