import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../widgets/cart_item.dart' as ci;
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
      ),
      body: CartBody(),
    );
  }
}

class CartBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final insideCart = cart.items.values.toList();
    return Column(
      children: <Widget>[
        Card(
          margin: EdgeInsets.all(15),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  width: 10,
                ),
                Spacer(),
                Chip(
                  label: Text(
                    '\$${cart.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryTextTheme.title.color,
                    ),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                FlatButton(
                  onPressed: () {
                    if (cart.items.values.toList().isEmpty) {
                      Scaffold.of(context).removeCurrentSnackBar();
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Cart is Empty!'),
                      ));
                    } else {
                      Provider.of<Orders>(context).addOrder(
                        cartProducts: cart.items.values.toList(),
                        total: cart.totalAmount,
                      );
                      cart.clear();
                    }
                  },
                  child: Text(
                    'ORDER NOW',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (ctx, index) => ci.CartItem(
              id: insideCart[index].id,
              price: insideCart[index].price,
              quantity: insideCart[index].quantity,
              title: insideCart[index].title,
            ),
            itemCount: insideCart.length,
          ),
        ),
      ],
    );
  }
}
