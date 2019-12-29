import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_details_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  // final String imageUrl;
  // final String title;
  // final String id;
  // ProductItem(this.imageUrl, this.title, this.id);
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(ProductDetailsScreen.routeName, arguments: product.id);
      },
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              color: Theme.of(context).accentColor,
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () => product.toggleFavoriteStatus(),
            ),
          ),
          title: Text(product.title),
          trailing: IconButton(
            color: Theme.of(context).accentColor,
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () =>
                cart.addItem(product.id, product.title, product.price),
          ),
        ),
        child: Hero(
          tag: product.id,
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
