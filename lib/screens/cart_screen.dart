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
                OrderButton(cart: cart),
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

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  //TODO: Use [FUTUREBUILDERS] in all these Stateful widgets and remove all
  //_isLoading variable
  @override
  Widget build(BuildContext context) {
    return FlatButton(
        textColor: Theme.of(context).primaryColor,
        onPressed:_isLoading||widget.cart.items.values.toList().isEmpty ? null: () async {
          setState(() {
            _isLoading = true;
          });
          await Provider.of<Orders>(context).addOrder(
            cartProducts: widget.cart.items.values.toList(),
            total: widget.cart.totalAmount,
          );
          setState(() {
            _isLoading = false;
          });
          widget.cart.clear();
        },
        child: _isLoading
              ? CircularProgressIndicator()
              : Text(
                  'ORDER NOW',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );
  }
}
