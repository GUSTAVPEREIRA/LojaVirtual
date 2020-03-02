import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/datas/cart_product_data.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {
  UserModel user;
  String couponCode;
  int discountPercentage = 0;
  bool isLoading = false;

  List<CartProductData> products = [];

  CartModel(this.user) {
    if (user.isLoggedIn()) {
      _loadCartItems();
    }
  }

  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  void addCartItem(CartProductData cartProductData) {
    products.add(cartProductData);
    Firestore.instance
        .collection('users')
        .document(user.firebaseUser.uid)
        .collection('cart')
        .add(cartProductData.toMap())
        .then((doc) {
      cartProductData.cid = doc.documentID;
    });

    notifyListeners();
  }

  void removeCartItem(CartProductData cartProductData) {
    Firestore.instance
        .collection('users')
        .document(user.firebaseUser.uid)
        .collection('cart')
        .document(cartProductData.cid)
        .delete();

    products.remove(cartProductData);
    notifyListeners();
  }

  void decProduct(CartProductData cartProductData) {
    cartProductData.quantity--;
    Firestore.instance
        .collection('users')
        .document(user.firebaseUser.uid)
        .collection('cart')
        .document(cartProductData.cid)
        .updateData(cartProductData.toMap());
    notifyListeners();
  }

  void incProduct(CartProductData cartProductData) {
    cartProductData.quantity++;
    Firestore.instance
        .collection('users')
        .document(user.firebaseUser.uid)
        .collection('cart')
        .document(cartProductData.cid)
        .updateData(cartProductData.toMap());
    notifyListeners();
  }

  void _loadCartItems() async {
    QuerySnapshot query = await Firestore.instance
        .collection('users')
        .document(user.firebaseUser.uid)
        .collection('cart')
        .getDocuments();

    products = query.documents
        .map((doc) => CartProductData.fromDocument(doc))
        .toList();
    notifyListeners();
  }

  void setCoupon(String couponCode, int discountPercentage) {
    this.couponCode = couponCode;
    this.discountPercentage = discountPercentage;
  }

  double getProductsPrice() {
    double price = 0.0;
    for (CartProductData c in products) {
      if (c.productData != null) {
        price += c.productData.price * c.quantity;
      }
    }

    return price;
  }

  double getShipPrice() {
    return 10.00;
  }

  double getDiscountPrice() {
    return (getProductsPrice() * discountPercentage) / 100;
  }

  void updatePrices() {
    notifyListeners();
  }

  Future<String> finishOrder() async {
    if (products.length == 0) {
      return null;
    }

    isLoading = true;
    notifyListeners();
    double productsPrice = getProductsPrice();
    double shipPrice = getShipPrice();
    double discount = getDiscountPrice();

    DocumentReference refOrder = await Firestore.instance.collection('orders').add({
      'clientId': user.firebaseUser.uid,
      'products': products.map((cartProducts) => cartProducts.toMap()).toList(),
      'shipPrice': shipPrice,
      'productsPrice': productsPrice,
      'discount': discount,
      'totalPrice': productsPrice - discount + shipPrice,
      'status': 1
    });

    await Firestore.instance.collection('users').document(user.firebaseUser.uid)
    .collection('orders').document(refOrder.documentID).setData({
      'orderId': refOrder.documentID
    });

    QuerySnapshot query = await Firestore.instance.collection('users').document(user.firebaseUser.uid)
    .collection('cart').getDocuments();

    for(DocumentSnapshot doc in query.documents) {
      doc.reference.delete();
    }

    products.clear();
    discountPercentage = 0;
    couponCode = null;
    isLoading = false;
    notifyListeners();
    return refOrder.documentID;

  }
}
