import 'package:flutter/material.dart';

import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String id;

  UserProductItem(this.id, this.title, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: ()=> Navigator.of(context).pushNamed(EditProductScreen.routeName, arguments: id),
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).errorColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
