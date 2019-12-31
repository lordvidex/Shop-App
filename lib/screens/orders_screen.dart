import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/order_item.dart' as ord;
import '../widgets/app_drawer.dart';
import '../providers/orders.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: ListView.builder(
        itemCount: orderData.items.length,
        itemBuilder: (ctx, index) => ord.OrderItem(orderData.items[index]),
      ),
    );
  }
}
