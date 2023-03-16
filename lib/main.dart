import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final storeProvider = FutureProvider<List<Product>>((ref) async {
  final response =
      await http.get(Uri.parse('https://fakestoreapi.com/products'));
  if (response.statusCode == 200) {
    final productsJson = json.decode(response.body);
    final products = <Product>[];
    for (final productJson in productsJson) {
      products.add(Product.fromJson(productJson));
    }
    return products;
  } else {
    throw Exception('Failed to load products');
  }
});

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Half Blood Prince's App",
      home: MyScreen(),
    );
  }
}

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products screen',
          textAlign: TextAlign.center,
        ),
      ),
      body: Consumer(builder: (context, ref, _) {
        final storeFuture = ref.watch(storeProvider);
        return storeFuture.when(
          data: (products) {
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: ListTile(
                    title: Text(product.title),
                    subtitle: Text(product.description),
                    trailing: Text(
                      '\$${product.price}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        );
      }),
    );
  }
}

class Product {
  final String title;
  final String description;
  final double price;

  Product({
    required this.title,
    required this.description,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['title'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
    );
  }
}
