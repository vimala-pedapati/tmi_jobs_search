import 'dart:convert';

import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmi_jobs_search/tmi_jobs_search_app.dart';

void main() async {
  /// Initialize packages
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Hive
  await Hive.initFlutter();

  /// Initialize Hive
  /// Open encrypted box in Hive to store auth session tokens
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  const hiveEncSSKey = 'HIVE_ENC_KEY_STORAGE';
  const hiveAuthSessionVault = 'HIVE_AUTH_SESSION_VAULT';
  // containsKey doesn't work on few iOS devices, so read the key value and check for null
  //var containsEncryptionKey = await secureStorage.containsKey(key: hiveEncSSKey);
  var base64EncodedEncryptionKey = await secureStorage.read(key: hiveEncSSKey);
  if (base64EncodedEncryptionKey == null) {
    var key = Hive.generateSecureKey();
    await secureStorage.write(key: hiveEncSSKey, value: base64UrlEncode(key));
  }
  var encryptionKey =
      base64Url.decode((await secureStorage.read(key: hiveEncSSKey))!);
  await Hive.openBox<String>(hiveAuthSessionVault,
      encryptionCipher: HiveAesCipher(encryptionKey));

  final authRepo = AuthenticationRepositary(
      authHiveBox: Hive.box<String>(hiveAuthSessionVault));
  final HttpLink httpLink = HttpLink("${BaseUrl.baseUrl}graphql");
  final AuthLink authLink = AuthLink(getToken: authRepo.getAccessTokenJwt);
  if (kDebugMode) {
    print(".....Endpoint: ${httpLink.uri}");
    print("...accessToken: ${authLink.getToken}");
  }
  final Link link = authLink.concat(httpLink);
  final sharedPreferences = await SharedPreferences.getInstance();
  ValueNotifier<GraphQLClient> graphqlClient = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
      defaultPolicies: DefaultPolicies(
          query: Policies(
              error: ErrorPolicy.all, fetch: FetchPolicy.cacheAndNetwork),
          mutate: Policies(
              error: ErrorPolicy.all, fetch: FetchPolicy.cacheAndNetwork)),
    ),
  );

  runApp(TmiJobSearchApp(
    authRepo: authRepo,
    graphQLClient: graphqlClient.value,
    prefs: sharedPreferences,
  ));
}
