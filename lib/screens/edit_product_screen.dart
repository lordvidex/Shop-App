import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/product_item_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _form = GlobalKey<FormState>();
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  var _editedProduct =
      Product(imageUrl: '', price: 0.0, title: '', id: null, description: '');

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }
  //add forms to the provider
  void _saveForm() {
    final isValid = _form.currentState.validate();
    if(!isValid){
      return ;
    }
    _form.currentState.save();
    Provider.of<ProductProvider>(context,listen: false).addProduct(_editedProduct);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _saveForm(),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            child: Form(
              key: _form,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (title) {
                        _editedProduct = Product(
                            title: title,
                            description: _editedProduct.description,
                            id: _editedProduct.id,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please return a valid title';
                        } else {
                          return null;
                        }
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (price) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          id: _editedProduct.id,
                          imageUrl: _editedProduct.imageUrl,
                          price: double.parse(price),
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a value';
                        } else if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        } else if (double.parse(value) <= 0) {
                          return 'Please enter a value greater than zero';
                        } else {
                          return null;
                        }
                      },
                    ),
                    TextFormField(
                        decoration: InputDecoration(labelText: 'Description'),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        focusNode: _descriptionFocusNode,
                        onSaved: (description) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              description: description,
                              id: _editedProduct.id,
                              imageUrl: _editedProduct.imageUrl,
                              price: _editedProduct.price);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter a valid description';
                          } else if (value.length <= 10) {
                            return 'Description is too short';
                          } else {
                            return null;
                          }
                        }),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _saveForm(),
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onSaved: (imageUrl) {
                              _editedProduct = Product(
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  id: _editedProduct.id,
                                  imageUrl: imageUrl,
                                  price: _editedProduct.price);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'No URL entered! Please Enter an image URL';
                              } else if (!value
                                      .toLowerCase()
                                      .endsWith('.jpg') &&
                                  !value.toLowerCase().endsWith('.png')) {
                                return 'Invalid image! Please enter a valid image URL';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
