import 'package:flutter/material.dart';
import 'package:odo_mobile_v2/providers/cart.dart';
import 'package:provider/provider.dart';

typedef CountButtonClickCallBack = void Function(dynamic count);

class CountButtonView extends StatefulWidget {
  final String itemId;
  final CountButtonClickCallBack onChange;
  final String parentCategory;
  final String parentBrandName;

  const CountButtonView({
    Key? key,
    required this.itemId,
    required this.onChange,
    required this.parentCategory,
    required this.parentBrandName,
  }) : super(key: key);

  @override
  _CountButtonViewState createState() => _CountButtonViewState();
}

class _CountButtonViewState extends State<CountButtonView> {
  dynamic quantity = 0;

  void updateCount(dynamic addValue) {
    if (quantity + addValue <= 0) {
      setState(() {
        quantity = 0;
      });
    }
    if (quantity + addValue > 0) {
      setState(() {
        quantity += addValue;
      });
    }

    widget.onChange(quantity);
    }

  @override
  Widget build(BuildContext context) {
    var count = Provider.of<CartProvider>(context, listen: false)
        .getQuantity(widget.itemId);
    setState(() {
      quantity = count;
    });

    return SafeArea(
      child: SizedBox(
        width: double.infinity - 100,
        height: 50.0,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 1.0),
              borderRadius: BorderRadius.circular(22.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    updateCount(-1);
                  },
                  onLongPress: () {
                    updateCount(-50);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.0),
                    ),
                    width: quantity < 100 ? 35 : 20,
                    child: const Center(
                      child: Text(
                        '-',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 4, 102, 7),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    '$quantity',
                    key: ValueKey<int>(quantity),
                    style: TextStyle(
                      fontSize: quantity < 100 ? 15.0 : 15.0,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 4, 102, 7),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    updateCount(1);
                  },
                  onLongPress: () {
                    updateCount(50);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.0),
                      color: Colors.white,
                    ),
                    width: quantity < 100 ? 32 : 32,
                    child: Center(
                      child: Text(
                        '+',
                        style: TextStyle(
                          fontSize: quantity < 100 ? 15.0 : 15.0,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 4, 102, 7),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
