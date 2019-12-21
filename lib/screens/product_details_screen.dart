import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/product_detail_screen';
  @override
  Widget build(BuildContext context) {
    final itemId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct =
        Provider.of<ProductProvider>(context).getProductById(itemId);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
      body: Center(
        child: Text(loadedProduct.description),
      ),
    );
  }
}
