import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';

class CharacterPageCharacter extends StatelessWidget {
  final String imageUrl;
  const CharacterPageCharacter({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.width * 1,
      width: size.width * 1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(120),
        border: Border.all(color: Colors.black, width: 0.8),
      ),
      child: Center(
        child: Image.network(
          imageUrl,
          width: size.width * 0.6,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Stack(
              alignment: Alignment.center,
              children: [
                child,
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: MainColors.mainLight),
                ),
              ],
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.pets, size: 100, color: Colors.grey[400]);
          },
        ),
      ),
    );
  }
}
