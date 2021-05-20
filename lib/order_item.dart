import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderItem extends StatefulWidget {
  final dynamic orderData;
  final int index;

  OrderItem(this.orderData, this.index);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  String _newStatus = '';

  @override
  Widget build(BuildContext context) {
    final amount = widget.orderData[widget.index]['amount'];
    final number = widget.orderData[widget.index]['number'];
    final request = widget.orderData[widget.index]['request'];
    final dateTime = widget.orderData[widget.index]['dateTime'].toDate();
    final address = widget.orderData[widget.index]['address'];
    final orderId = widget.orderData[widget.index]['orderId'];
    final charges = widget.orderData[widget.index]['charges'];
    final status = widget.orderData[widget.index]['status'];
    final items = List.from(widget.orderData[widget.index]['items']);
    status == 'Preparing'
        ? _newStatus = 'Out for Delivery'
        : status == 'Out for Delivery'
            ? _newStatus = 'Delivered'
            : _newStatus = 'Delivered!';
    return Column(
      children: [
        ListTile(
          title: Text(
            'ORDER #${orderId.toString().substring(0, 6).toUpperCase()}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Ordered on: ${DateFormat('dd/MM/yyyy @ hh:mmaa').format(dateTime)}',
          ),
          trailing: IconButton(
            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
        ),
        Container(
          color: status == "Preparing"
              ? Colors.orange
              : status == "Out for Delivery"
                  ? Colors.yellow
                  : status == "Cancelled"
                      ? Colors.red
                      : Colors.green,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(status),
          ),
        ),
        if (_expanded) Divider(),
        if (_expanded)
          Column(
            children: [
              Text('Address: $address'),
              Text('Number: $number'),
              Text('Special Request: $request'),
              TextButton(
                onPressed: () {
                  //launch(urlString)
                },
                child: Text('Open in Map'),
              ),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: items
                    .map(
                      (prod) => ListTile(
                        title: Text(
                          prod.toString().split("_")[0],
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${prod.toString().split("_")[1]} x ₹${prod.toString().split("_")[2]}',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        trailing: Text(
                          '₹${prod.toString().split("_")[2]}',
                        ),
                      ),
                    )
                    .toList(),
              ),
              ListTile(
                title: Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  '₹${(amount * (charges + 1)).toStringAsFixed(1)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: _newStatus != "Delivered!"
                    ? () {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Text('Mark $_newStatus?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('orders')
                                          .doc(orderId)
                                          .update(
                                        {'status': _newStatus},
                                      );
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                ],
                              );
                            });
                      }
                    : () {},
                child: _newStatus == 'Delivered!'
                    ? Text(_newStatus)
                    : Text('Mark $_newStatus'),
              )
            ],
          ),
        Divider(
          thickness: 15,
        ),
      ],
    );
  }
}
