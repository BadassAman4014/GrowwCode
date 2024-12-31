import 'package:flutter/material.dart';

class HorizontalMenu extends StatelessWidget {
  final List<String> names;
  final List<String> images;
  final Function(int) onTap;

  HorizontalMenu({
    required this.names,
    required this.images,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(names.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: GestureDetector(
                  onTap: () {
                    onTap(index);
                  },
                  child: Card(
                    elevation: 4, // Creates the elevated card effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded edges
                    ),
                    child: SizedBox(
                      width: 115, // Set a fixed width for consistency
                      height: 150, // Set a fixed height for the card
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 85,
                              height: 85,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(images[index]),
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            SizedBox(
                              width: 115, // Match width to the card
                              child: Text(
                                names[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                                maxLines: 2, // Limit text to 2 lines
                                overflow: TextOverflow.ellipsis, // Add ellipsis for long text
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
