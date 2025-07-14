import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odo_mobile_v2/providers/orders.dart';
import 'package:provider/provider.dart';

class OrderCard extends StatelessWidget {
  final String? status;
  final String? placedOn;
  final String? dispatchOn;
  final String? orderId;
  final num? order_total;
  final num? subTotal;

  const OrderCard(
      {Key? key,
      this.status,
      this.placedOn,
      this.dispatchOn,
      this.orderId,
      this.order_total,
      this.subTotal})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color.fromARGB(255, 235, 229, 229)),
        height: 200,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 4.0),
              child: Row(
                children: [
                  const Text(
                    "Status ",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 138, 137, 137),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    status!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  status == 'Accepted'
                      ? const Icon(
                          Icons.task_alt_sharp,
                          color: Color.fromARGB(255, 46, 126, 50),
                          size: 25,
                        )
                      : const SpinKitPulse(
                          size: 35,
                          color: Color.fromARGB(255, 253, 169, 43),
                        ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black,
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  "Dispatch On : ${dispatchOn}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Placed On : ${placedOn}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                dense: true,
              ),
            ),
            Expanded(
              child: ListTile(
                title: status == "Accepted"
                    ? Text(
                        "Total : Rs.${order_total}",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.lineThrough),
                      )
                    : Text(
                        "Estimated Total : Rs.${order_total}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                subtitle: status == "Accepted"
                    ? Text(
                        "Dispatched Total : Rs.${subTotal}",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      )
                    : const Text(
                        "(This might change based on items we dispatch.)",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
