import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/product_item.dart';

class ProductsGride extends StatelessWidget {
  final bool showFavs;
  ProductsGride(this.showFavs);

  @override
 Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products = showFavs ? productData.favoritesItems : productData.items;
    return products.isEmpty
        ? Center(child: Text("There is no product!"))
        : GridView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: products.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: products[i],
              child: ProductItem(),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          );
  }
}
