import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DraggableModal extends StatefulWidget {
  final String url;

  const DraggableModal({super.key, required this.url});

  @override
  State<DraggableModal> createState() => _DraggableModalState();
}

class _DraggableModalState extends State<DraggableModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late WebViewController _webViewController;

  late double minHeight;

  late double halfHeight;

  late double maxHeight;

  late double currentHeight;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _webViewController =
        WebViewController()..loadRequest(Uri.parse(widget.url));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      maxHeight = screenHeight * 0.95;
      halfHeight = screenHeight * 0.5;
      minHeight = screenHeight * 0.075;
      currentHeight = halfHeight;

      _heightAnimation = AlwaysStoppedAnimation(currentHeight);
      setState(() {});
    });
  }

  void _animateTo(double targetHeight) {
    _heightAnimation = Tween<double>(
      begin: currentHeight,
      end: targetHeight,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    )..addListener(() {
      setState(() {
        currentHeight = _heightAnimation.value;
      });
    });

    _animationController
      ..reset()
      ..forward();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      currentHeight = (currentHeight - details.delta.dy).clamp(
        minHeight,
        maxHeight,
      );
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -700 || currentHeight > maxHeight * 0.75) {
      _animateTo(maxHeight);
    } else if (velocity > 700 || currentHeight < maxHeight * 0.3) {
      _animateTo(minHeight);
    } else {
      _animateTo(halfHeight);
    }
  }

  void _closeOrCollapse() {
    if (currentHeight == minHeight) {
      Navigator.pop(context);
    } else {
      _animateTo(minHeight);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: Container(
        height: currentHeight + bottomInset,
        padding: EdgeInsets.only(bottom: bottomInset),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: TextButton.icon(
                onPressed: _closeOrCollapse,
                icon: Icon(
                  currentHeight == minHeight
                      ? Icons.close
                      : Icons.expand_more_outlined,
                ),
                label: Text(
                  currentHeight == minHeight ? 'Закрити' : 'Згорнути',
                ),
              ),
            ),

            Expanded(child: WebViewWidget(controller: _webViewController)),
          ],
        ),
      ),
    );
  }
}
