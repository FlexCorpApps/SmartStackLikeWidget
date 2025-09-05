import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ClickStack extends Stack {
  const ClickStack({super.key, required super.children});
  @override
  ClickStackRender createRenderObject(BuildContext context) {
    return ClickStackRender(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.of(context),
      fit: fit,
    );
  }
}

class ClickStackRender extends RenderStack {
  ClickStackRender({
    required super.alignment,
    super.textDirection,
    required super.fit,
  });
  bool hitChildren(BoxHitTestResult result, {Offset? position}) {
    bool stackHit = false;
    final List<RenderBox> children = getChildrenAsList();
    for (final RenderBox child in children) {
      final StackParentData childData = child.parentData as StackParentData;
      final bool hitChild = result.addWithPaintOffset(
        offset: childData.offset,
        position: position!,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (hitChild) {
        stackHit = true;
      }
    }
    return stackHit;
  }
}

final PageController defaultPageController = PageController();

enum StackedCardCarouselType { cardsStack }

typedef OnPageChanged = void Function(int pageIndex);


class SmartStackLikeWidget extends StatefulWidget {
  SmartStackLikeWidget({
    super.key,
    required this.items,
    this.initialOffset =40.0,
    this.spaceBetweenItemsInStack = 40.0,
    this.spaceBetweenItems = 400,
    this.applyTextScaleFactor = true,
    this.scrollDirection = Axis.vertical,
    this.scrollDirectionReverse = true,
    PageController? pageController,
    this.onPageChanged,
  }) : assert(items.isNotEmpty), pageController = pageController ?? defaultPageController;
  final List<Widget> items;
  final double initialOffset;
  final double spaceBetweenItemsInStack;
  final double spaceBetweenItems;
  final bool applyTextScaleFactor;
  final Axis scrollDirection;
  final bool scrollDirectionReverse;
  final PageController pageController;
  final OnPageChanged? onPageChanged;
  @override
  SmartStackLikeWidgetState createState() => SmartStackLikeWidgetState();
}

class SmartStackLikeWidgetState extends State<SmartStackLikeWidget> {
  double pageValue = 0.0;
  
  @override
  Widget build(BuildContext context) {
    widget.pageController.addListener(() {
      if (mounted) {
        setState(() {
          pageValue = widget.pageController.page!;
        });
      }
    });
    return ClickStack(
      children: <Widget>[
        stackedCards(context),
        PageView.builder(
          scrollDirection: widget.scrollDirection,
          reverse: widget.scrollDirectionReverse,
          controller: widget.pageController,
          itemCount: widget.items.length,
          onPageChanged: widget.onPageChanged,
          itemBuilder: (BuildContext context, int index) => Container(),
        ),
      ],
    );
  }

  Widget stackedCards(BuildContext context) {
    final List<Widget> positionedCards = widget.items.asMap().entries.map((
        MapEntry<int, Widget> item) {
      double position = widget.initialOffset;

      if (pageValue < item.key) {
        position += (pageValue - item.key) * widget.spaceBetweenItems;
      }

      double scale = 1.0; // größe der karten
      if (item.key - pageValue < 0) {
        final double factor = 1 + (item.key - pageValue);
        scale = 0.95 + (factor * 0.1 / 2);
      }

      return Positioned.fill(
        top: position - (widget.spaceBetweenItemsInStack * item.key), // position der karten
        child: Align(
          alignment: Alignment.center,
          child: Wrap(
            children: <Widget>[
              Transform.scale(scale: scale, child: item.value),
            ],
          ),
        ),
      );
    }).toList();

    return Stack(
      alignment: Alignment.bottomCenter,
      fit: StackFit.passthrough,
      children: positionedCards,
    );
  }
}