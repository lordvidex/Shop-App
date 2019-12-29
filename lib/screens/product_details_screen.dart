import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_item_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/product_detail_screen';
  @override
  Widget build(BuildContext context) {
    final itemId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct = Provider.of<ProductProvider>(
      context,
      listen: false,
    ).getProductById(itemId);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Hero(
            tag: loadedProduct.id,
            child: Image.network(
              loadedProduct.imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            '\$${loadedProduct.price}',
            style: TextStyle(color: Colors.grey, fontSize: 20),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: Text(
              loadedProduct.description,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )),
    );
  }
}
