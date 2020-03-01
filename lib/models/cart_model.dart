import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/datas/cart_product_data.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {

  UserModel user;

  bool isLoading = false;

  List<CartProductData> products = [];

  CartModel(this.user) {
    if(user.isLoggedIn()) {
      _loadCartItems();
    }
  }

  static CartModel of(BuildContext context) => ScopedModel.of<CartModel>(context);

  void addCartItem(CartProductData cartProductData) {

    products.add(cartProductData);
    Firestore.instance.collection('users').document(user.firebaseUser.uid)
    .collection('cart').add(cartProductData.toMap()).then((doc) {
      cartProductData.cid = doc.documentID;
    });

    notifyListeners();
  }

  void removeCartItem(CartProductData cartProductData) {

    Firestore.instance.collection('users').document(user.firebaseUser.uid)
        .collection('cart').document(cartProductData.cid).delete();

    products.remove(cartProductData);
    notifyListeners();
  }

  void decProduct(CartProductData cartProductData) {
    cartProductData.quantity--;
    Firestore.instance.collection('users').document(user.firebaseUser.uid).collection('cart')
    .document(cartProductData.cid).updateData(cartProductData.toMap());
    notifyListeners();
  }

  void incProduct(CartProductData cartProductData) {
    cartProductData.quantity++;
    Firestore.instance.collection('users').document(user.firebaseUser.uid).collection('cart')
        .document(cartProductData.cid).updateData(cartProductData.toMap());
    notifyListeners();
  }

  void _loadCartItems() async {
    QuerySnapshot query = await Firestore.instance.collection('users').document(user.firebaseUser.uid).collection('cart')
        .getDocuments();

    products = query.documents.map((doc) => CartProductData.fromDocument(doc)).toList();
    notifyListeners();


  }

}