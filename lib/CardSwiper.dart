// ignore: file_names
import 'dart:math';
import 'package:flutter/material.dart';

class CardSwiper extends StatefulWidget {
  const CardSwiper({
    super.key,
    required this.onPressed,
    required this.results,
  });
  final List<String> results;
  final Function(int i) onPressed;

  @override
  State<CardSwiper> createState() => _CardSwiperState();
}

class _CardSwiperState extends State<CardSwiper> {
  final FixedExtentScrollController _controller = FixedExtentScrollController();
  final backCard = const AssetImage('assets/images/card_back.png');
  int indexSelected = -1;
  int currentIndex = 0;
  String imageResult = '';
  bool isAnimating = false;

  void handleSelectCardPressed() {
    if (imageResult != "") {
      setState(() {
        indexSelected = -1;
        imageResult = '';
      });
      _controller.animateTo(
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

  void _firstScrollListener() {
    // print("flutter123 current ${_controller.selectedItem}");
    // int circleCount = (_controller.offset / 1080).floor();
    // print("flutter123 ${_controller.offset} $circleCount ${_controller.offset - (circleCount * 1080)}");

    if (indexSelected != -1) {
      if (isAnimating) return;
      setState(() {
        indexSelected = -1;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(_firstScrollListener);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_firstScrollListener)
      ..dispose();
    super.dispose();
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
                  child: ListWheelScrollView.useDelegate(
                    controller: _controller,
                    itemExtent: 120,
                    squeeze: 1.7,
                    clipBehavior: Clip.none,
                    offAxisFraction: 1.5,
                    onSelectedItemChanged: (value) {
                      currentIndex = value;
                    },
                    diameterRatio: 4.5,
                    renderChildrenOutsideViewport: true,
                    // physics: imageResult == "" ? null : const NeverScrollableScrollPhysics(),
                    physics:
                        imageResult == "" ? const FixedExtentScrollPhysics() : const NeverScrollableScrollPhysics(),
                    childDelegate: ListWheelChildLoopingListDelegate(
                      children: List.generate(
                        10,
                        (index) {
                          return _Card(
                            index: index,
                            key: Key(index.toString()),
                            image: backCard,
                            isActive: indexSelected == index,
                            onPress: () {
                              isAnimating = true;

                              _controller.position.restoreOffset(currentIndex * 120);
                              double totalWidth = index * 120;

                              if (indexSelected < index && index - indexSelected > 3) {
                                if (index == 9) totalWidth = -120;
                                if (index == 8) totalWidth = -240;
                                if (index == 7) totalWidth = -360;
                              } else if (indexSelected > index && indexSelected - index > 6) {
                                if (index == 0) totalWidth = 1080 + 120;
                                if (index == 1) totalWidth = 1080 + 240;
                                if (index == 2) totalWidth = 1080 + 360;
                              }

                              _controller.animateTo(
                                totalWidth,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                              );

                              if (indexSelected < index && index - indexSelected > 3) {
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  _controller.animateTo(
                                    index * 120,
                                    duration: const Duration(milliseconds: 1),
                                    curve: Curves.linear,
                                  );
                                });
                              } else if (indexSelected > index && indexSelected - index > 6) {
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  _controller.animateTo(
                                    index * 120,
                                    duration: const Duration(milliseconds: 1),
                                    curve: Curves.linear,
                                  );
                                });
                              }

                              setState(() {
                                indexSelected = indexSelected == index ? -1 : index;
                              });

                              Future.delayed(const Duration(milliseconds: 300), () {
                                isAnimating = false;
                              });
                              // });
                            },
                          );
                        },
                      ),
                    ),
                  ),
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
    required this.index,
  });

  final Function() onPress;
  final bool isActive;
  final int index;
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
