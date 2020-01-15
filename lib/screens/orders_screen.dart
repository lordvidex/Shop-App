import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/order_item.dart' as ord;
import '../widgets/app_drawer.dart';
import '../providers/orders.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (context, snapshot) {
            if (snapshot.error != null) {
              //error handling
              return Center(child: Text(snapshot.error.toString()));
            } else {
              //no error
              if (snapshot.connectionState == ConnectionState.done) {
                return Consumer<Orders>(
                  builder: (ctx, orderData, _) => ListView.builder(
                    itemCount: orderData.items.length,
                    itemBuilder: (ctx, index) =>
                        ord.OrderItem(orderData.items[index]),
                  ),
                );
              }
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
