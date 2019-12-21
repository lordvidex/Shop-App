import 'package:flutter/material.dart';

import '../screens/product_details_screen.dart';
class ProductItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String id;
  ProductItem(this.imageUrl, this.title, this.id);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed(ProductDetailsScreen.routeName,arguments: id);
      },
          child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          leading: IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              //TODO: complete function
            },
          ),
          title: Text(title),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: (){},
          ),
        ),
        child: Image.network(imageUrl,fit: BoxFit.cover,),
      ),
    );
  }
}
