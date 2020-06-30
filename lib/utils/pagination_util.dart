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
  
  */*/*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:flutter/foundation.dart';
import 'package:dog_pal/utils/extensions_util.dart';

class PaginationUtil {
  @visibleForTesting
  bool noMoreDocuments = false;

  @visibleForTesting
  Query activeQuery;

  @visibleForTesting
  List<DocumentSnapshot> allDocs = [];

  @visibleForTesting
  DocumentSnapshot lastDocument;

  Query firstQuery; //town query
  Query secondQuery; //city query
  Query thirdQuery; //district query

  Future<List<DocumentSnapshot>> getDogs() async {
    noMoreDocuments = false;

    QuerySnapshot querySnapshot;

    activeQuery = firstQuery ?? secondQuery ?? thirdQuery;

    assert(activeQuery != null);

    allDocs.clear();

    do {
      querySnapshot =
          await activeQuery.limit(FirestoreConsts.DOCS_LIMIT).getDocuments();

      allDocs.addAll(querySnapshot.documents);

      if (querySnapshot.documents.length < FirestoreConsts.DOCS_LIMIT) {
        if (activeQuery == thirdQuery) {
          noMoreDocuments = true;
          lastDocument = null;
        }
        _incrementQuery();
      } else {
        //enough docs
        lastDocument = querySnapshot.documents.last;
        break;
      }
    } while (activeQuery != null);

    return allDocs.deDup();
  }

  void _incrementQuery() {
    if (activeQuery == firstQuery) {
      activeQuery = secondQuery ?? thirdQuery;
    } else if (activeQuery == secondQuery) {
      activeQuery = thirdQuery;
    } else if (activeQuery == thirdQuery) {
      activeQuery = null;
    }
  }

  Future<List<DocumentSnapshot>> loadMoreData() async {
    if (noMoreDocuments) {
      return null;
    } else {
      assert(activeQuery != null);

      QuerySnapshot querySnapshot;

      do {
        if (lastDocument == null) {
          querySnapshot = await activeQuery
              .limit(FirestoreConsts.DOCS_LIMIT)
              .getDocuments();
        } else {
          querySnapshot = await activeQuery
              .startAfterDocument(lastDocument)
              .limit(FirestoreConsts.DOCS_LIMIT)
              .getDocuments();
        }
        allDocs.addAll(querySnapshot.documents);

        // No more documents in the query
        if (querySnapshot.documents.length < FirestoreConsts.DOCS_LIMIT) {
          if (activeQuery == thirdQuery) {
            noMoreDocuments = true;
          }
          lastDocument =
              null; // The next time we load more data we're using a new query

          _incrementQuery();
        } else {
          lastDocument = querySnapshot.documents.last;
          break;
        }
      } while (!noMoreDocuments);

      return allDocs.deDup();
    }
  }
}
