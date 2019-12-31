import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/order_item.dart' as ord;

import '../providers/orders.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
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
