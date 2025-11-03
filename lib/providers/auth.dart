import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:odo_mobile_v2/models/area.dart';
import 'package:odo_mobile_v2/models/distributor.dart';
import 'package:odo_mobile_v2/models/referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  List<Area> _areas = [];
  List<Referrer> _referrers = [];
  Map<String , Distributor> _distributors = {};

  String loggedInDistributor = "";
  String loggedInArea = "";
  String activePriceList = "";
  String activeDistributorKey = "";
  Distributor? activeDistributor = null;
  String loggedInShop = "";
  String loggedIncontact = "";
  String loggedInGSTNumber = "";
  String loggedInShopAddress = "";
  String loggedInLatitude = "";
  String loggedInLongitude = "";
  String loggedInReferrerId = "";
  String darkStoreIdForOrder = ""; // different strategies to find this , currently we find through referrerId.

  String dbURL = "https://odo-admin-app-default-rtdb.asia-southeast1.firebasedatabase.app/";
  String? _deviceToken = "";

  String? get deviceToken {
    return _deviceToken;
  }

  List<Area> get areas {
    return [..._areas];
  }

  List<String> get areaNames {
    return [..._areas].map((e) => e.areaName).toList();
  }

  List<String> get referrerNames =>
    _referrers.map((e) => e.referrerName).toList()..sort();


  Map<String , Distributor> get distributors {
    return {..._distributors};
  }

  List<String> get distributorNames {
  return _distributors.values
      .map((distributor) => distributor.distributorName)
      .toList();
}


   void setActiveDistributor(Distributor distributor) {
    activeDistributor = distributor;
    notifyListeners(); // Notify widgets to rebuild
  }

  setupNotifications() async {
    FirebaseMessaging fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    _deviceToken = await fcm.getToken();
    notifyListeners();
  }

  Future<void> distributorSignUp(String distributorName, String area,
      String GSTNumber, String shop,String contactNumber,String shopAddress , String latitude , String longitude , String referrer , String selfieUrl , String referrerId) async {
    //send http post here.
    const url =
        "https://odo-admin-app-default-rtdb.asia-southeast1.firebasedatabase.app/DistributorNotifications.json";
    await http.post(Uri.parse(url),
        body: json.encode({
          'name': distributorName,
          'area': area,
          'GST': GSTNumber,
          'contact': contactNumber,
          'shop' : shop,
          'deviceToken': _deviceToken,
          'shopAddress' : shopAddress,
          'latitude' : latitude,
          'longitude' : longitude,
          'referrer': referrer == "" ? "not-mentioned" : referrer,
          'selfieUrl': selfieUrl,
          'referrerId': referrerId,
        }));
  }

  Future<void> fetchAreasFromDB() async {
    const url = "https://odo-admin-app-default-rtdb.asia-southeast1.firebasedatabase.app/Areas.json";
    
    try {
      final response = await http.get(Uri.parse(url));
      final List<Area> loadedAreas = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData.forEach((shopId, areaData) {
        loadedAreas.add(Area(areaName: areaData['areaName']));
      });
      _areas = loadedAreas;
      _areas.sort(
        (a, b) => a.areaName.compareTo(b.areaName),
      );
      notifyListeners();
    } catch (error) {
      rethrow; //will pass upward.
    }
  }

  Future<void> fetchReferrersFromDB() async {
    const url = "https://odo-admin-app-default-rtdb.asia-southeast1.firebasedatabase.app/ReferralLeaderboard.json";
    try {
      final response = await http.get(Uri.parse(url));
      final List<Referrer> loadedReferrers = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData.forEach((referrerId, referrerData) {
        print(referrerData);
        loadedReferrers.add(Referrer(referrerName: referrerData['businessName']??"no-business-name-attached" , referrerId: referrerId));
      });
      _referrers = loadedReferrers;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchDarkStoreFromReferrerId(String referrerId) async {
    var url = "https://odo-admin-app-default-rtdb.asia-southeast1.firebasedatabase.app/ReferralLeaderboard/${referrerId}.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      darkStoreIdForOrder = extractedData['darkStoreId'] ?? "not-found";
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  String? getReferrerIdByName(String referrerName) {
    try {
      //referrerName means businessName , ODO1
      return _referrers.firstWhere((referrer) => referrer.referrerName == referrerName).referrerId;
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchDistributorsFromDB() async {
  const url =
      "https://odo-admin-app-default-rtdb.asia-southeast1.firebasedatabase.app/Distributors.json";
  try {
    final response = await http.get(Uri.parse(url));
    final Map<String, Distributor> loadedDistributors = {};
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    extractedData.forEach((distributorId, distributorData) {
      final contact = distributorData['contact'].toString();
      loadedDistributors[contact] = Distributor(
        id: distributorId,
        area: distributorData['area'],
        distributorName: distributorData['name'],
        shop: distributorData['shop'],
        contact: contact,
        referrerId: distributorData['referrerId'] ?? "not-found",
        attached_price_list: "normal-price-list",
        shopAddress: distributorData['shopAddress'].toString(),
        latitude: distributorData['latitude']?.toString() ?? "not-found",
        longitude: distributorData['longitude']?.toString() ?? "not-found",
        GSTNumber: distributorData['GST'],
      );
    });

    _distributors = loadedDistributors; // Now a Map<String, Distributor>
    notifyListeners();
  } catch (error) {
    rethrow;
  }
}


  Future<void> loadLoggedInDistributorData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    loggedInDistributor =
        sharedPreferences.getString("loggedInDistributor").toString();
    loggedInArea = sharedPreferences.getString("loggedInArea").toString();
    activePriceList = sharedPreferences.getString("priceList").toString();
    activeDistributorKey =
        sharedPreferences.getString("distributorKey").toString();
    loggedInShop = sharedPreferences.getString("loggedInShop").toString();
    loggedIncontact = sharedPreferences.getString("loggedIncontact").toString();
    loggedInGSTNumber = sharedPreferences.getString("loggedInGSTNumber").toString();
    loggedInShopAddress = sharedPreferences.getString("loggedInShopAddress").toString();
    loggedInLatitude = sharedPreferences.getString("latitude").toString();
    loggedInLongitude = sharedPreferences.getString("longitude").toString();
    loggedInReferrerId = sharedPreferences.getString("referrerId").toString();
    notifyListeners();
  }

  Future<void> setLoggedInDistributorAndArea(Distributor distributor) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString("loggedInDistributor", distributor.distributorName);
    sharedPreferences.setString("loggedInArea", distributor.area);
    sharedPreferences.setString("priceList", "normal");
    sharedPreferences.setString("loggedInShop" , distributor.shop);
    sharedPreferences.setString("loggedIncontact" , distributor.contact);
    sharedPreferences.setString("loggedInGSTNumber",distributor.GSTNumber);
    sharedPreferences.setString("loggedInShopAddress" , distributor.shopAddress);
    sharedPreferences.setString("distributorKey", distributor.id);
    sharedPreferences.setString("latitude", distributor.latitude);
    sharedPreferences.setString("longitude", distributor.longitude);
    sharedPreferences.setString("referrerId", distributor.referrerId);
    loggedInDistributor = distributor.distributorName;
    loggedInArea = distributor.area;
    activePriceList = "normal";
    activeDistributorKey = distributor.id;
    notifyListeners();
  }

  Future<void> logout() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }

  Future<void> deleteAccount() async {
    var url =
        "https://odo-admin-app-default-rtdb.asia-southeast1.firebasedatabase.app/$activeDistributorKey.json";
    try {
      await http.delete(Uri.parse(url));
    } catch (error) {
      rethrow;
    }
  }

  //this is to invalidate session of loggedInDistributor if he is no longer active now.
  //makes a call to firebase function which return true or false.
  Future<bool> checkDistributorContact(String contact) async {
  final url = Uri.parse(
    'https://checkdistributorcontact-jipkkwipyq-uc.a.run.app',
  );

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'contact': contact}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['exists'] == true;
    } else {
      print('Server error: ${response.statusCode} -> ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error calling Cloud Function: $e');
    return false;
  }
}

bool isNoOrderUser()
{
  print(activeDistributor);
  if(loggedInDistributor == ("NO-ORDER-USER") && loggedIncontact=="8888888888")
  {
    return true;
  }
  return false;
}

}
