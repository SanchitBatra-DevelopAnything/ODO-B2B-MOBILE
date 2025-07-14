import 'package:flutter/material.dart';
import 'package:odo_mobile_v2/providers/orders.dart';
import 'package:provider/provider.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedOrder = Provider.of<OrderProvider>(context, listen: false)
        .selectedOrderForDetail;
    print(selectedOrder.items[0]);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 65.0,
              color: Colors.white,
              padding: const EdgeInsets.only(left: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      color: Colors.white,
                      child: Card(
                        elevation: 0.0,
                        margin: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedOrder.status == "Accepted"
                                        ? "Order Summary"
                                        : "Order Details",
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    "${selectedOrder.items.length} items in this order",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffdd0e1c)),
                                  )
                                ],
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: selectedOrder.items.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  ListTile(
                                      // dense: true,
                                      title: Text(
                                        selectedOrder.status == "Accepted"
                                            ? "${selectedOrder.items[index]['item']} x ${selectedOrder.items[index]['dispatchedQuantity']}"
                                            : "${selectedOrder.items[index]['item']} x ${selectedOrder.items[index]['quantity']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: selectedOrder.status ==
                                              "Accepted"
                                          ? Text(
                                              'You ordered: ${selectedOrder.items[index]['orderedQuantity']}')
                                          : const Text(""),
                                      trailing: selectedOrder.status ==
                                              "Accepted"
                                          ? selectedOrder.items[index]
                                                      ['orderedQuantity'] !=
                                                  selectedOrder.items[index]
                                                      ['dispatchedQuantity']
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Rs.${selectedOrder.items[index]['dispatchedPrice']}",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      'Rs.${selectedOrder.items[index]['orderedPrice']}',
                                                      style: const TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  "Rs.${selectedOrder.items[index]['dispatchedPrice']}",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                          : Text(
                                              "Rs.${selectedOrder.items[index]['price']}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    selectedOrder.status == "Accepted"
                        ? Container(
                            color: Colors.white,
                            child: Card(
                              elevation: 0.0,
                              margin: EdgeInsets.zero,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'Bill Details (GST incl.)',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text('Order Total'),
                                    trailing:
                                        Text('Rs.${selectedOrder.totalPrice}'),
                                  ),
                                  ListTile(
                                    title: const Text('Dispatch Price'),
                                    trailing: Text(
                                        'Rs.${selectedOrder.totalDispatchPrice}'),
                                  ),
                                  ListTile(
                                    title: const Text('Discount',
                                        style: TextStyle(
                                            color: Color(0xff008800))),
                                    trailing: Text(
                                      'Rs.${selectedOrder.discount}',
                                      style:
                                          const TextStyle(color: Color(0xff008800)),
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text(
                                      'Sub Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Text(
                                      'Rs.${selectedOrder.subTotal}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    const SizedBox(height: 8.0),
                    Container(
                      color: Colors.white,
                      child: Card(
                        elevation: 0.0,
                        margin: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Order Details',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ListTile(
                              title: const Text('Order id'),
                              subtitle: Text('${selectedOrder.id}'),
                            ),
                            ListTile(
                              title: const Text('Order placed'),
                              subtitle: Text('${selectedOrder.orderTime}'),
                            ),
                            ListTile(
                              title: const Text('Requested dispatch date'),
                              subtitle: Text('${selectedOrder.dispatchDate}'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
