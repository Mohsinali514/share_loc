import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomMarkerWidget extends StatelessWidget {
  const CustomMarkerWidget({required this.imageUrl, super.key});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circular image
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                imageUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Triangle pointer
        CustomPaint(
          size: const Size(20, 10),
          painter: TrianglePainter(),
        ),
      ],
    );
  }
}

// Dummy triangle painter class for illustration
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
