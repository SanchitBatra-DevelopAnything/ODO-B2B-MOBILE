import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/acceptedOrder.dart';
import '../models/pendingOrder.dart';
import 'package:http/http.dart' as http;

class OrderProvider with ChangeNotifier {
  List<PendingOrder> _pendingOrders = [];
  List<AcceptedOrder> _acceptedOrders = [];

  dynamic selectedOrderForDetail;

  List<dynamic> _allOrders = [];

  List<dynamic> get allOrders {
    return [..._allOrders];
  }

  setSelectedOrderForDetail(dynamic order) {
    selectedOrderForDetail = order;
  }

  Future<void> getPendingOrders(
      String loggedInDistributor, String loggedInArea) async {
    var url =
        "https://kidysadminapp-default-rtdb.firebaseio.com/activeDistributorOrders/$loggedInArea/$loggedInDistributor.json";
    try {
      final response = await http.get(Uri.parse(url));
      if (response == 'null') {
        _pendingOrders = [];
        return;
      }
      final List<PendingOrder> loadedPendingOrders = [];
      if (json.decode(response.body) == null) {
        _pendingOrders = [];
        return;
      }
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData.forEach((orderId, orderData) {
        print(orderData);
        loadedPendingOrders.add(PendingOrder(
          status: "Pending",
          area: orderData['area'],
          id: orderId,
          items: orderData['items'],
          dispatchDate: orderData['dispatchDate'],
          orderDate: orderData['orderDate'],
          orderTime: orderData['orderTime'],
          orderedBy: orderData['orderedBy'],
          totalPrice: orderData['totalPrice'],
        ));
      });
      _pendingOrders = loadedPendingOrders;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getAcceptedOrders(
      String loggedInDistributor, String loggedInArea) async {
    var params = "orderBy=\"\$key\"&limitToFirst=50";
    var url =
        "https://kidysadminapp-default-rtdb.firebaseio.com/processedDistributorOrders/$loggedInArea/$loggedInDistributor.json?$params";
    try {
      final response = await http.get(Uri.parse(url));
      if (response == 'null') {
        _acceptedOrders = [];
        return;
      }
      final List<AcceptedOrder> loadedAcceptedOrders = [];
      if (json.decode(response.body) == null) {
        _acceptedOrders = [];
        return;
      }
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData.forEach((orderId, orderData) {
        loadedAcceptedOrders.add(AcceptedOrder(
          status: "Accepted",
          area: orderData['area'],
          id: orderId,
          items: orderData['items'],
          discount: orderData['discount'],
          subTotal: orderData['subTotal'],
          dispatchDate: orderData['dispatchDate'],
          orderDate: orderData['orderDate'],
          orderTime: orderData['orderTime'],
          orderedBy: orderData['orderedBy'],
          totalPrice: orderData['totalPrice'],
          totalDispatchPrice: orderData['totalDispatchPrice'],
          orderKey: orderData['orderKey'],
        ));
      });
      _acceptedOrders = loadedAcceptedOrders;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAllOrdersList(
      String loggedInDistributor, String loggedInArea) async {
    await getPendingOrders(loggedInDistributor, loggedInArea);
    await getAcceptedOrders(loggedInDistributor, loggedInArea);
    _allOrders = [
      ..._pendingOrders.reversed.toList(),
      ..._acceptedOrders.reversed.toList()
    ];
    notifyListeners();
  }
}
