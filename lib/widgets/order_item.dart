import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;
  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  AnimationController _controller;
  Animation<double> _angleAnimation;
  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _angleAnimation = Tween<double>(begin: 0, end: pi).animate(
        CurvedAnimation(curve: Curves.fastOutSlowIn, parent: _controller));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('\$${widget.order.amount.toStringAsFixed(2)}'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
              ),
              trailing: AnimatedBuilder(
                animation: _angleAnimation,
                child: IconButton(
                  icon: Icon(Icons.expand_more),
                  onPressed: () {
                    if (!_expanded) {
                      _controller.forward();
                    } else {
                      _controller.reverse();
                    }
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
                builder: (ctx, ch) => Transform.rotate(
                  angle: _angleAnimation.value,
                  child: ch,
                ),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
              padding: EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 10,
              ),
              height: _expanded
                  ? min(widget.order.products.length * 20.0 + 10, 100)
                  : 0,
              child: ListView(
                children: widget.order.products
                    .map(
                      (prod) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            prod.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text('${prod.quantity}x  \$${prod.price}'),
                        ],
                      ),
                    )
                    .toList(),
              ),
            )
          ],
        ));
  }
}
