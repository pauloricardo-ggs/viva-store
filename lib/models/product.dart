import 'dart:convert';

class Product {
  String id;
  String photo;
  String name;
  String description;
  double price;
  double height;
  double width;
  double lenght;
  double weight;
  int stock;
  int discountPercentage;
  String category;

  Product({
    this.id = "",
    required this.photo,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.height,
    required this.width,
    required this.lenght,
    required this.weight,
    required this.stock,
    required this.discountPercentage,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'photo': photo,
      'name': name,
      'description': description,
      'price': price,
      'height': height,
      'width': width,
      'lenght': lenght,
      'weight': weight,
      'stock': stock,
      'discountPercentage': discountPercentage,
      'category': category,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      photo: map['photo'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as double,
      height: map['height'] as double,
      width: map['width'] as double,
      lenght: map['lenght'] as double,
      weight: map['weight'] as double,
      stock: map['stock'] as int,
      discountPercentage: map['discountPercentage'] as int,
      category: map['category'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) => Product.fromMap(json.decode(source) as Map<String, dynamic>);
}
