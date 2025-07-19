import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/distributorOrderItem.dart';

class CartItem {
  final String id;
  final String title;
  final num quantity;
  final dynamic price; //MRP
  final String imageUrl;
  final String parentCategoryType;
  final dynamic totalPrice; //MRP*QUANTITY
  final dynamic discount_percentage;
  final dynamic totalPriceAfterDiscount;
  final dynamic slab_1_start;
  final dynamic slab_1_end;
  final dynamic slab_1_discount;

  final dynamic slab_2_start;
  final dynamic slab_2_end;
  final dynamic slab_2_discount;

  final dynamic slab_3_start;
  final dynamic slab_3_end;
  final dynamic slab_3_discount;
  final String parentBrandName;

  CartItem(
      {required this.id,
      required this.title,
      required this.imageUrl,
      required this.parentCategoryType,
      required this.quantity,
      required this.totalPrice,
      required this.price,
      required this.discount_percentage,
      required this.totalPriceAfterDiscount,
      required this.slab_1_start,
      required this.slab_1_end,
      required this.slab_1_discount,
      required this.slab_2_start,
      required this.slab_2_end,
      required this.slab_2_discount,
      required this.slab_3_start,
      required this.slab_3_end,
      required this.parentBrandName,
      required this.slab_3_discount,});

  Map toJson() => {
        'id': id,
        'title': title,
        'quantity': quantity,
        'price': price,
        'imageUrl': imageUrl,
        'parentCategoryType': parentCategoryType,
        'parentBrandName':parentBrandName,
        'totalPrice': totalPrice,
        'discount_percentage' : discount_percentage,
        'totalPriceAfterDiscount' : totalPriceAfterDiscount,
        'slab_1_start': slab_1_start,
      'slab_1_end': slab_1_end,
      'slab_1_discount': slab_1_discount,
      'slab_2_start': slab_2_start,
      'slab_2_end': slab_2_end,
      'slab_2_discount': slab_2_discount,
      'slab_3_start': slab_3_start,
      'slab_3_end': slab_3_end,
      'slab_3_discount': slab_3_discount,
      };
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem>? _items = {}; //product db id as key.

  List<CartItem> _itemList = [];

  String dispatchDateSelected = "";

  Map<String, CartItem> get items {
    return {..._items!};
  }

  List<CartItem> get itemList {
    return [..._itemList];
  }

  int get itemCount {
    if (_items == null) {
      return 0;
    }
    return _items!.length;
  }

  bool checkInCart(String itemId) {
    return _items!.containsKey(itemId);
  }

  dynamic getQuantity(String itemId) {
    if (checkInCart(itemId)) {
      CartItem? item = _items![itemId];
      return item!.quantity;
    } else {
      return 0;
    }
  }

  void setDispatchDate(String date) {
    dispatchDateSelected = date;
    notifyListeners();
  }

  void resetDispatchDate() {
    dispatchDateSelected = "";
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    _itemList = [];
    notifyListeners();
  }

  num getTotalOrderPrice({bool isMrpCalculated = false}) {
    double totalPrice = 0;
    if(isMrpCalculated)
    {
      //actual MRP Total.
      for (var element in _itemList) {
        totalPrice += element.totalPrice;
      }
    }
    else
    {
        //total discountedPrice
        for (var element in _itemList) {
          totalPrice += element.totalPriceAfterDiscount;
      }
    }
  // Truncate to two decimal places
  return (totalPrice * 100).truncateToDouble() / 100;
  }

  void removeItem(String itemId) {
    if (checkInCart(itemId)) {
      _items!.remove(itemId);
      formCartList();
      notifyListeners();
    }
  }

  void formCartList() {
    _itemList = [];
    _items!.forEach((key, value) {
      _itemList.add(CartItem(
          id: key,
          totalPrice: value.totalPrice,
          imageUrl: value.imageUrl,
          parentCategoryType: value.parentCategoryType,
          parentBrandName: value.parentBrandName,
          price: value.price,
          quantity: value.quantity,
          discount_percentage : value.discount_percentage,
          totalPriceAfterDiscount : value.totalPriceAfterDiscount,
          title: value.title,
          slab_1_start : value.slab_1_start,
          slab_1_end : value.slab_1_end,
          slab_1_discount : value.slab_1_discount,
          slab_2_start : value.slab_2_start,
          slab_2_end : value.slab_2_end,
          slab_2_discount : value.slab_2_discount,
          slab_3_start : value.slab_3_start,
          slab_3_end : value.slab_3_end,
          slab_3_discount : value.slab_3_discount));
    });
    print("LIST OF CART BECOMES = ");
    for (var ci in _itemList) {
      print(
        "${ci.id} , has quantity ${ci.quantity} , title ${ci.title} ,Total =  ${ci.totalPrice}");
    }
    notifyListeners();
  }

  // double getPriceFromString(String price) {
  //   var p = price.substring(3);
  //   return double.parse(p);
  // }

  void addItem(String itemId, num price, num quantity, String title,
      String imgPath, String parentCategory , String parentBrandName,dynamic slab1Start , dynamic slab1End , dynamic slab1Discount
      , dynamic slab2Start , dynamic slab2End , dynamic slab2Discount, dynamic slab3Start, dynamic slab3End,dynamic slab3Discount) {
    print(
        "REQUEST TO ADD $title with price ${price.toString()} and quantity $quantity , making total = ${(price * quantity).toString()}");
        var discountPercent = calculateDiscount(slab1Start,slab1End,slab2Start,slab2End,slab3Start,slab3End,slab1Discount,slab2Discount,slab3Discount , quantity);

    if (_items!.containsKey(itemId)) {
      //change quantity..
      print("Found update quantity = $quantity");
      _items!.update(
          itemId,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              totalPrice: existingCartItem.price * quantity,
              title: existingCartItem.title,
              imageUrl: existingCartItem.imageUrl,
              parentCategoryType: existingCartItem.parentCategoryType,
              parentBrandName: existingCartItem.parentBrandName,
              price: existingCartItem.price,
              quantity: quantity,
              discount_percentage : discountPercent,
              totalPriceAfterDiscount : calculatePriceByDiscountFormula(price , quantity,discountPercent),
              slab_1_start : slab1Start,
              slab_1_end : slab1End,
              slab_2_start : slab2Start,
              slab_2_end : slab2End,
              slab_3_start : slab3Start,
              slab_3_end : slab3End,
              slab_1_discount : slab1Discount,
              slab_2_discount : slab2Discount,
              slab_3_discount : slab3Discount));
    } else {
      _items!.putIfAbsent(
          itemId,
          () => CartItem(
              id: "$itemId-CART",
              totalPrice: price * quantity,
              price: price,
              title: title,
              quantity: quantity, //not using 1 as we were seeing race conditions.
              imageUrl: imgPath,
              parentCategoryType: parentCategory,
              parentBrandName: parentBrandName,
              discount_percentage : discountPercent,
              totalPriceAfterDiscount : calculatePriceByDiscountFormula(price , quantity , discountPercent),
              slab_1_start : slab1Start,
              slab_1_end : slab1End,
              slab_2_start : slab2Start,
              slab_2_end : slab2End,
              slab_3_start : slab3Start,
              slab_3_end : slab3End,
              slab_1_discount : slab1Discount,
              slab_2_discount : slab2Discount,
              slab_3_discount : slab3Discount));
    }
    print("Formin list");
    formCartList();
    notifyListeners();

    print("ADDED ITEM");
  }

  dynamic calculatePriceByDiscountFormula(dynamic price , dynamic quantity , dynamic discountPercentage)
  {
    var factor = (discountPercentage/100);
    var totalPrice = price*quantity;

    var discountCalculatedPrice = totalPrice - (factor*totalPrice);
    return discountCalculatedPrice;
  }

  dynamic calculateDiscount(dynamic slab1Start , dynamic slab1End , dynamic slab2Start , dynamic slab2End 
  , dynamic slab3Start , dynamic slab3End , dynamic slab1Discount, dynamic slab2Discount,dynamic slab3Discount , num quantity)
  {
    if(quantity>=slab1Start && quantity<=slab1End)
    {
      return slab1Discount;
    }
    if(quantity>=slab2Start && quantity<=slab2End)
    {
      return slab2Discount;
    }
    if(quantity>=slab3Start && quantity<=slab3End)
    {
      return slab3Discount;
    }
    return 0;
  }

  Future<void> PlaceDistributorOrder(String area, String loggedInDistributor,
      String time, String activePriceList, String deviceToken , String shop , String GST , String contact , String shopAddress , String latitude , String longitude) async {
    var todaysDate = DateTime.now();
    var year = todaysDate.year.toString();
    var month = todaysDate.month.toString();
    var day = todaysDate.day.toString();
    var date = "$day-$month-$year";
    var url =
        "https://odo-admin-app-default-rtdb.asia-southeast1.firebasedatabase.app/activeDistributorOrders.json";
    try {
      await http.post(Uri.parse(url),
          body: json.encode({
            "area": area,
            "shop" : shop,
            "GST" : GST,
            "shopAddress" : shopAddress,
            "orderedBy": loggedInDistributor,
            "orderTime": time,
            "orderDate": date,
            "contact" : contact,
            "items": formOrderItemList(),
            "deviceToken": deviceToken,
            "totalPrice": getTotalOrderPrice(isMrpCalculated : true),
            "totalPriceAfterDiscount" : getTotalOrderPrice(isMrpCalculated: false),
            "delivery-latitude" : latitude,
            "delivery-longitude" : longitude
          }));
    } catch (error) {
      print("ERROR IS");
      print(error);
      rethrow;
    }
  }

  Future<void> deleteCartOnDB(String member, String memberKey) async {
    var url =
        "http://10.0.2.2:8080/v1/cart/delete/${memberKey}";
    try {
      await http.delete(Uri.parse(url));
    } catch (error) {
      print("ERROR IS");
      print(error);
      rethrow;
    }
  }

  Future<void> saveCart(String member, String memberKey) async {
    var url =
        "http://10.0.2.2:8080/v1/cart/save/${memberKey}";
    try {
      await http.put(Uri.parse(url),
      headers: {"Content-Type": "application/json"},
          body: json.encode({"items": formSaveCartList()}));
    } catch (error) {
      print("ERROR IS");
      print(error);
      rethrow;
    }
  }

  Future<void> fetchCartFromDB(String distributor, String area) async {
    var url =
        "https://odo-admin-app-default-rtdb.asia-southeast1.firebasedatabase.app/cart/$area/$distributor/items.json";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.body == 'null') {
        print("NULLL AAGYI DB WALE CART");
        return;
      }
      // final List<CartItem> loadedItems = [];
      final extractedData = json.decode(response.body) as List<dynamic>;
      for (var cartItem in extractedData) {
        // loadedItems.add(CartItem(
        //     id: cartItem['id'],
        //     imageUrl: cartItem['imageUrl'],
        //     parentCategoryType: cartItem['parentCategoryType'],
        //     parentSubcategoryType: cartItem['parentSubcategoryType'],
        //     price: cartItem['price'],
        //     quantity: cartItem['quantity'],
        //     title: cartItem['title'],
        //     totalPrice: cartItem['totalPrice']));
        addItem(
          cartItem['id'],
          cartItem['price'],
          cartItem['quantity'],
          cartItem['title'],
          cartItem['imageUrl'],
          cartItem['parentCategoryType'],
          cartItem['parentBrandName'],
          cartItem['slab_1_start'],
          cartItem['slab_1_end'],
          cartItem['slab_1_discount'],
          cartItem['slab_2_start'],
          cartItem['slab_2_end'],
          cartItem['slab_2_discount'],
          cartItem['slab_3_start'],
          cartItem['slab_3_end'],
          cartItem['slab_3_discount']
        );
      }
    } catch (error) {
      print("ERROR IS");
      print(error);
      rethrow;
    }
  }

  formSaveCartList() {
    var items = [];
    for (var cartItem in itemList) {
      items.add(cartItem.toJson());
    }
    return items;
  }

  formOrderItemList() {
    var items = [];
    for (var cartItem in _itemList) {
      var discountPercent = calculateDiscount(cartItem.slab_1_start,cartItem.slab_1_end,cartItem.slab_2_start,cartItem.slab_2_end,cartItem.slab_3_start,cartItem.slab_3_end,cartItem.slab_1_discount,cartItem.slab_2_discount,cartItem.slab_3_discount , cartItem.quantity);
      items.add(DistributorOrderItem(
              item: cartItem.title,
              brand: cartItem.parentCategoryType,
              quantity: cartItem.quantity,
              price: cartItem.totalPrice,
              priceAfterDiscount : cartItem.totalPriceAfterDiscount,
              discount_percentage : discountPercent)
          .toJson());
    }
    return items;
  }
}
