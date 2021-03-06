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
  var prodId;
  var _isLoading = false;
  String appBarTitle = 'Add Product';
  final _form = GlobalKey<FormState>();
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  var _editedProduct =
      Product(imageUrl: '', price: 0.0, title: '', id: null, description: '');

  var _initPage = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
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

  @override
  void didChangeDependencies() {
    if (!_initPage) {
      prodId = ModalRoute.of(context).settings.arguments as String;
      if (prodId != null) {
        appBarTitle = 'Edit Product';
        _editedProduct = Provider.of<ProductProvider>(context, listen: false)
            .getProductById(prodId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'imageUrl': '',
          'price': _editedProduct.price.toString(),
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
      _initPage = true;
    }
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  //add forms to the provider
  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (prodId != null) {
      try{
      await Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(prodId, _editedProduct);
      }catch(error){
        print(error);
      }finally{
        setState((){
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    } else {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error Occured'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveForm(),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
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
                            initialValue: _initValues['title'],
                            decoration: InputDecoration(labelText: 'Title'),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_priceFocusNode);
                            },
                            onSaved: (title) {
                              _editedProduct = Product(
                                title: title,
                                description: _editedProduct.description,
                                id: _editedProduct.id,
                                imageUrl: _editedProduct.imageUrl,
                                price: _editedProduct.price,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                            validator: (value) {
                              return value.isEmpty
                                  ? 'Please return a valid title'
                                  : null;
                            },
                          ),
                          TextFormField(
                            initialValue: _initValues['price'],
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
                                isFavorite: _editedProduct.isFavorite,
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
                              initialValue: _initValues['description'],
                              decoration:
                                  InputDecoration(labelText: 'Description'),
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              focusNode: _descriptionFocusNode,
                              onSaved: (description) {
                                _editedProduct = Product(
                                  title: _editedProduct.title,
                                  description: description,
                                  id: _editedProduct.id,
                                  imageUrl: _editedProduct.imageUrl,
                                  price: _editedProduct.price,
                                  isFavorite: _editedProduct.isFavorite,
                                );
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
                                  decoration:
                                      InputDecoration(labelText: 'Image URL'),
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
                                        isFavorite: _editedProduct.isFavorite,
                                        price: _editedProduct.price);
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'No URL entered! Please Enter an image URL';
                                    } else if (!value
                                            .toLowerCase()
                                            .endsWith('.jpg') &&
                                        !value
                                            .toLowerCase()
                                            .endsWith('.jpeg') &&
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
