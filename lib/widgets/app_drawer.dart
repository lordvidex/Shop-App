import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import './badge.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<Orders>(context, listen: false);
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello Friend'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: orders.items.length == 0
                ? Text('Orders')
                : Badge(
                  alignment: Alignment.centerLeft,
                    value: orders.items.length.toString(),
                    child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('Orders',textAlign: TextAlign.left,)),
                  ),
            onTap: () =>
                Navigator.pushReplacementNamed(context, OrdersScreen.routeName),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () => Navigator.pushReplacementNamed(context, UserProductsScreen.routeName),
          ),
        ],
      ),
    );
  }
}
