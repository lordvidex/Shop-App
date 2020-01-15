import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_item_provider.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-product';

  Future<void> _refreshAndFetch(BuildContext context) async {
    try {
      await Provider.of<ProductProvider>(context).fetchAndSetProducts();
    } catch (error) {
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Error'),
                content: Text(error.toString()),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  )
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, EditProductScreen.routeName);
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshAndFetch(context),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Consumer<ProductProvider>(
            builder: (ctx, productData, _) => ListView.builder(
              itemCount: productData.items.length,
              itemBuilder: (ctx, index) => Column(
                children: <Widget>[
                  UserProductItem(
                      productData.items[index].id,
                      productData.items[index].title,
                      productData.items[index].imageUrl),
                  Divider(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
