import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/datas/cart_product_data.dart';
import 'package:loja_virtual/datas/product_data.dart';
import 'package:loja_virtual/models/cart_model.dart';

class CardTile extends StatefulWidget {
  final CartProductData cartProductData;
  CardTile(this.cartProductData);

  @override
  _CardTileState createState() => _CardTileState(this.cartProductData);
}

class _CardTileState extends State<CardTile> {
  final CartProductData cartProductData;

  _CardTileState(this.cartProductData);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      child: cartProductData.productData == null
          ? FutureBuilder<DocumentSnapshot>(
              future: Firestore.instance
                  .collection('products')
                  .document(cartProductData.category)
                  .collection('items')
                  .document(cartProductData.pid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  cartProductData.productData =
                      ProductData.fromDocument(snapshot.data);
                  return _buildContent();
                } else {
                  return Container(
                    height: 70.0,
                    child: CircularProgressIndicator(),
                    alignment: Alignment.center,
                  );
                }
              },
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 120.0,
          child: Image.network(
            cartProductData.productData.images[0],
            fit: BoxFit.cover,
          ),
        ),
        Expanded(
            child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                cartProductData.productData.title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17.0,
                ),
              ),
              Text(
                'Tamanho: ${cartProductData.size}',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                'R\$ ${cartProductData.productData.price.toStringAsFixed(2)}',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.remove,
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: cartProductData.quantity > 1 ? () {
                      CartModel.of(context).decProduct(cartProductData);
                    } : null,
                  ),
                  Text(cartProductData.quantity.toString()),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      CartModel.of(context).incProduct(cartProductData);
                    },
                  ),
                  FlatButton(
                    onPressed: () {
                      CartModel.of(context).removeCartItem(cartProductData);
                    },
                    child: Text('Remover'),
                    textColor: Colors.grey[500],
                  )
                ],
              )
            ],
          ),
        ))
      ],
    );
  }
}
