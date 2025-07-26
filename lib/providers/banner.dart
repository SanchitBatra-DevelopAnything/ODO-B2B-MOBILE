import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:odo_mobile_v2/models/bannerModel.dart';
import 'package:provider/provider.dart';

import '../models/cataegory.dart';
import 'package:http/http.dart' as http;


class BannerProvider with ChangeNotifier {

  List<BannerModel> _banners = [];
  
  

  List<BannerModel> get banners {
    return [..._banners];
  }



  Future<void> fetchBannersFromDB() async {
    const url =
        "http://10.0.2.2:8080/v1/B2BBanners";
    try {
      final response = await http.get(Uri.parse(url));
      final List<BannerModel> loadedBanners = [];
      print(response.body);
      if (response.body == "null") {
        _banners = loadedBanners;
      notifyListeners();
  print("Server response is null or empty.");
  return; // Return an empty map or handle it as needed
}
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData.forEach((bannerId, bannerData) {
        loadedBanners.add(BannerModel(
            
            imageUrl: bannerData['imageUrl'],
            ));
      });
      _banners = loadedBanners;
      notifyListeners();
    } catch (error) {
      print("Banners FETCH FAILED!");
      rethrow;
    }
  }
}