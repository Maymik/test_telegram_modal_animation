import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DraggableModal extends StatefulWidget {
  const DraggableModal({super.key, required this.url});

  final String url;

  @override
  State<DraggableModal> createState() => _DraggableModalState();
}

class _DraggableModalState extends State<DraggableModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late WebViewController _webViewController;
  double minHeight = 0;
  double halfHeight = 0;
  double maxHeight = 0;
  double currentHeight = 0;

  ModalState _currentState = ModalState.half;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                _webViewController.runJavaScript('''
            document.body.style.overflow = 'auto';
            document.documentElement.style.overflow = 'auto';
            document.body.style.touchAction = 'auto';
            document.documentElement.style.touchAction = 'auto';
          ''');
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  void _animateTo(double targetHeight) {
    if (targetHeight == maxHeight) {
      _currentState = ModalState.max;
    } else if (targetHeight == halfHeight) {
      _currentState = ModalState.half;
    } else {
      _currentState = ModalState.min;
    }

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

    if (velocity.abs() > 500) {
      if (velocity < 0) {
        if (_currentState == ModalState.min) {
          _animateTo(halfHeight);
        } else {
          _animateTo(maxHeight);
        }
      } else {
        if (_currentState == ModalState.max) {
          _animateTo(halfHeight);
        } else {
          _animateTo(minHeight);
        }
      }
    } else {
      final heightRatio = currentHeight / maxHeight;

      if (heightRatio > 0.75) {
        _animateTo(maxHeight);
      } else if (heightRatio > 0.35) {
        _animateTo(halfHeight);
      } else {
        _animateTo(minHeight);
      }
    }
  }

  void _closeOrCollapse() {
    if (_currentState == ModalState.min) {
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
    final screenHeight = MediaQuery.of(context).size.height;

    if (maxHeight == 0) {
      maxHeight = screenHeight * 0.95;
      halfHeight = screenHeight * 0.5;
      minHeight = screenHeight * 0.075;
      currentHeight = halfHeight;
      _heightAnimation = AlwaysStoppedAnimation(currentHeight);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }

    return Container(
      height: currentHeight + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 65,
              width: double.infinity,
              color: Colors.transparent,
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
                        _currentState == ModalState.min
                            ? Icons.close
                            : Icons.expand_more_outlined,
                      ),
                      label: Text(
                        _currentState == ModalState.min
                            ? 'Закрити'
                            : 'Згорнути',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  return true;
                },
                child: WebViewWidget(
                  controller: _webViewController,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer(),
                    ),

                    Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                    Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ModalState { min, half, max }
