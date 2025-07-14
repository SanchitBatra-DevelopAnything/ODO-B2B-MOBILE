import 'package:flutter/material.dart';

class DistributorOrderItem {
  final String item;
  final num quantity;
  final num price;
  final String brand;
  final num discount_percentage;
  final num priceAfterDiscount;

  DistributorOrderItem(
      {required this.item,
      required this.brand,
      required this.quantity,
      required this.discount_percentage,
      required this.priceAfterDiscount,
      required this.price});

  Map toJson() => {
        'item': item,
        'brand': brand,
        'quantity': quantity,
        'price': price,
        'discount_percentage' : discount_percentage,
        'priceAfterDiscount' : priceAfterDiscount
      };
}
