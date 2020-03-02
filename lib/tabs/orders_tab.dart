import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:loja_virtual/screens/login_screen.dart';
import 'package:loja_virtual/tiles/order_tile.dart';

class OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if(UserModel.of(context).isLoggedIn()) {
      String uid = UserModel.of(context).firebaseUser.uid;

      //Como vou obter todos os documentos de uma coleção é querysnapshot
      return FutureBuilder<QuerySnapshot>(
        future: Firestore.instance.collection('users').document(uid)
          .collection('orders').getDocuments(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView(
              children: snapshot.data.documents.map((doc) => OrdersTile(doc.documentID)).toList(),
            );
          }
      );

    } else {
      return Container(
        padding: EdgeInsets.only(right: 16.0, left: 16.0, top: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.view_list,
              color: Theme.of(context).primaryColor,
              size: 50.0,
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              'Faça o login para a compra!',
              textAlign: TextAlign.center,
              style:
              TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            RaisedButton(
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              color: Theme.of(context).primaryColor,
              child: Text(
                'Entrar',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
