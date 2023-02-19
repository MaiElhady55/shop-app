import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/products_grid.dart';

enum FilterOption { Favorites, All }

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({Key ?key}) : super(key: key);

  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _isLoading = false;
  var _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) => setState(
              () => _isLoading = false,
            ))
        .catchError((_) => setState(
              () => _isLoading = false,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: [
          PopupMenuButton(
              onSelected: (FilterOption selectedVal) {
                setState(() {
                  if (selectedVal == FilterOption.Favorites) {
                    _showOnlyFavorites = true;
                  } else {
                    _showOnlyFavorites = false;
                  }
                });
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('Only Favorites'),
                      value: FilterOption.Favorites,
                    ),
                    PopupMenuItem(
                      child: Text('Show All'),
                      value: FilterOption.All,
                    ),
                  ]),
          Consumer<Cart>(
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () =>Navigator.pushNamed(context, CartScreen.routeName),
              ),
              builder: (_,cart,ch)=>Badge(child: ch!, value: cart.itemCount.toString()))
        ],
      ),
      body: _isLoading? Center(child: CircularProgressIndicator()):ProductsGride(_showOnlyFavorites),
      drawer: AppDrawer(),
    );
  }
}
