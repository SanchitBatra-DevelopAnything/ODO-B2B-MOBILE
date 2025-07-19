import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odo_mobile_v2/providers/cart.dart';
import 'package:provider/provider.dart';

import 'itemCounterButton.dart';

class CartItemView extends StatefulWidget {
  final CartItem cartItem;
  const CartItemView({Key? key, required this.cartItem}) : super(key: key);

  @override
  _CartItemViewState createState() => _CartItemViewState();
}

class _CartItemViewState extends State<CartItemView> {
  @override
  Widget build(BuildContext context) {
    final cartProviderObject = Provider.of<CartProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Flexible(
          flex: 5,
          child: CachedNetworkImage(
            imageUrl: widget.cartItem.imageUrl,
            fit: BoxFit.cover,
            height: 80,
            width: 80,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                const SpinKitPulse(
              color: Color(0xffdd0e1c),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          flex: 7,
          fit: FlexFit.tight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.cartItem.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'MRP Total : Rs.${widget.cartItem.totalPrice}',
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Margin : Rs.${widget.cartItem.discount_percentage}%',
                style: const TextStyle(color: Colors.green, fontSize: 14),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                'You Pay : Rs.${widget.cartItem.totalPriceAfterDiscount.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 6,
          fit: FlexFit.tight,
          child: SizedBox(
            height: 35,
            child: CountButtonView(
                itemId: widget.cartItem.id,
                parentCategory: widget.cartItem.parentCategoryType,
                parentBrandName:widget.cartItem.parentBrandName,
                onChange: (count) => {
                      if (count == 0)
                        {
                          cartProviderObject.removeItem(widget.cartItem.id),
                        }
                      else if (count > 0)
                        {
                          cartProviderObject.addItem(
                            widget.cartItem.id,
                            widget.cartItem.price,
                            count,
                            widget.cartItem.title,
                            widget.cartItem.imageUrl,
                            widget.cartItem.parentCategoryType,
                            widget.cartItem.parentBrandName,
                            widget.cartItem.slab_1_start,
                                        widget.cartItem.slab_1_end,
                                        widget.cartItem.slab_1_discount,
                                        widget.cartItem.slab_2_start,
                                        widget.cartItem.slab_2_end,
                                        widget.cartItem.slab_2_discount,
                                        widget.cartItem.slab_3_start,
                                        widget.cartItem.slab_3_end,
                                        widget.cartItem.slab_3_discount
                          )
                        }
                    }),
          ),
        )
      ]),
    );
  }
}
