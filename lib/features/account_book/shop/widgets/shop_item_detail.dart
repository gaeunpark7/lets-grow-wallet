import 'package:flutter/material.dart';

class ShopItemDetail extends StatefulWidget {
  String image;
  String name;
  String price;
  String description;
  ShopItemDetail({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.description,
  });

  @override
  State<ShopItemDetail> createState() => _ShopItemDetailState();
}

class _ShopItemDetailState extends State<ShopItemDetail> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.16,
                width: MediaQuery.of(context).size.width * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: Text(
                    widget.image,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("가격:${widget.price}"),
                  SizedBox(height: 8),
                  Text(widget.description),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
