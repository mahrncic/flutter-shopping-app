import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_item.dart' as ord;

class OrderItem extends StatelessWidget {
  final ord.OrderItem order;

  const OrderItem(this.order);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${order.amount}'),
            subtitle: Text(
              DateFormat('dd MM yyy hh:mm').format(
                order.dateTime,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.expand_more,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
