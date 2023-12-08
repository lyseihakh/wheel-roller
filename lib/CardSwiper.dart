// ignore: file_names
import 'dart:math';
import 'package:flutter/material.dart';

class CardSwiper extends StatefulWidget {
  const CardSwiper({
    super.key,
    required this.cardCount,
    required this.onPressed,
    required this.results,
  });
  final List<String> results;
  final int cardCount;
  final Function(int i) onPressed;

  @override
  State<CardSwiper> createState() => _CardSwiperState();
}

class _CardSwiperState extends State<CardSwiper> {
  final FixedExtentScrollController _controller = FixedExtentScrollController();
  final backCard = const AssetImage('assets/images/card_back.png');
  int indexSelected = -1;
  String imageResult = '';

  void handleSelectCardPressed() {
    if (imageResult != "") {
      setState(() {
        indexSelected = -1;
        imageResult = '';
      });
      _controller.animateToItem(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.linear,
      );
      return;
    }
    // doing random stuff
    var intValue = Random().nextInt(widget.results.length);
    setState(() {
      imageResult = widget.results[intValue];
    });
    // trigger selected callback
    widget.onPressed(intValue);
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Expanded(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: height * 0.2),
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RotatedBox(
                  quarterTurns: 1,
                  child: ListWheelScrollView(
                      controller: _controller,
                      itemExtent: 120,
                      squeeze: 1.7,
                      clipBehavior: Clip.none,
                      offAxisFraction: 1.5,
                      diameterRatio: 4.5,
                      renderChildrenOutsideViewport: true,
                      physics: imageResult == "" ? null : const NeverScrollableScrollPhysics(),
                      children: List.generate(widget.cardCount, (index) {
                        return _Card(
                          key: Key(index.toString()),
                          image: backCard,
                          isActive: indexSelected == index,
                          onPress: () {
                            _controller.animateToItem(
                              index,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.linear,
                            );
                            setState(() {
                              indexSelected = indexSelected == index ? -1 : index;
                            });
                          },
                        );
                      })),
                ),
                imageResult != "" ? Image(image: AssetImage(imageResult), width: 200, height: 260) : const SizedBox()
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 80),
            child: ElevatedButton(
              onPressed: indexSelected == -1 ? null : handleSelectCardPressed,
              child: Text(imageResult != "" ? "Reset" : "Select Card"),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    super.key,
    required this.onPress,
    required this.isActive,
    required this.image,
  });

  final Function() onPress;
  final bool isActive;
  final ImageProvider<Object> image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Align(
        heightFactor: 4,
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(left: isActive ? 30 : 0),
          transform: Matrix4.translationValues(20.0, 0.0, 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.centerLeft,
          width: 200,
          child: RotatedBox(
            quarterTurns: 1,
            child: Image(image: image, width: 200, height: 200),
          ),
        ),
      ),
    );
  }
}
