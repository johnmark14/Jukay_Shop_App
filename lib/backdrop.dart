import 'package:shrine/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'model/product.dart' as prod;

const double _kFlingVelocity = 2.0;

class _BackdropTitle extends AnimatedWidget {
  final void Function() onPress;
  final Widget frontTitle;
  final Widget backTitle;

  const _BackdropTitle({
    Key? key,
    required Animation<double> listenable,
    required this.onPress,
    required this.frontTitle,
    required this.backTitle,
  })  : _listenable = listenable,
        super(key: key, listenable: listenable);

  final Animation<double> _listenable;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = _listenable;

    return DefaultTextStyle(
      style: Theme.of(context).primaryTextTheme.headline6!,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: Row(
        children: [
          SizedBox(
            width: 72.0,
            child: IconButton(
              padding: EdgeInsets.only(right: 8.0),
              onPressed: this.onPress,
              icon: Stack(
                children: [
                  Opacity(
                    opacity: animation.value,
                    child: ImageIcon(AssetImage('assets/slanted_menu.png')),
                  ),
                  FractionalTranslation(
                    translation: Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(1.0, 0.0),
                    ).evaluate(animation),
                    child: ImageIcon(AssetImage('assets/diamond.png')),
                  )
                ],
              ),
            ),
          ),
          Stack(
            children: [
              Opacity(
                opacity: CurvedAnimation(
                  parent: ReverseAnimation(animation),
                  curve: Interval(0.5, 1.0),
                ).value,
                child: FractionalTranslation(
                  translation: Tween<Offset>(
                    begin: Offset.zero,
                    end: Offset(0.5, 0.0),
                  ).evaluate(animation),
                  child: Semantics(
                    label: 'hide categories menu',
                    child: ExcludeSemantics(
                      child: backTitle,
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Interval(0.5, 1.0),
                ).value,
                child: FractionalTranslation(
                  translation: Tween<Offset>(
                    begin: Offset(-0.25, 0.0),
                    end: Offset.zero,
                  ).evaluate(animation),
                  child: Semantics(
                    label: 'show categories menu',
                    child: ExcludeSemantics(child: frontTitle),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class Backdrop extends StatefulWidget {
  final prod.Category currencyCategory;
  final Widget frontLayer;
  final Widget backLayer;
  final Widget frontTitle;
  final Widget backTitle;

  const Backdrop({
    required this.currencyCategory,
    required this.frontLayer,
    required this.backLayer,
    required this.frontTitle,
    required this.backTitle,
  });

  @override
  _BackdropState createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  final GlobalKey _backdropkey = GlobalKey(debugLabel: 'Backdrop');

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(microseconds: 300),
      value: 1.0,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Backdrop old) {
    super.didUpdateWidget(old);

    if (widget.currencyCategory != old.currencyCategory) {
      _toggleBackdropLayerVisibility();
    } else if (!_frontLayerVisible) {
      _controller.fling(velocity: _kFlingVelocity);
    }
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const double layerTitleHeight = 48.0;
    final Size layerSize = constraints.biggest;
    final double layerTop = layerSize.height - layerTitleHeight;

    Animation<RelativeRect> layerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
          0.0, layerTop, 0.0, layerTop - layerSize.height),
      end: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_controller.view);

    return Stack(
      key: _backdropkey,
      children: <Widget>[
        ExcludeSemantics(
          child: widget.backLayer,
          excluding: _frontLayerVisible,
        ),
        PositionedTransition(
          rect: layerAnimation,
          child: _FrontLayer(
              onTap: _toggleBackdropLayerVisibility, child: widget.frontLayer),
        )
      ],
    );
  }

  bool get _frontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBackdropLayerVisibility() {
    _controller.fling(
        velocity: _frontLayerVisible ? -_kFlingVelocity : _kFlingVelocity);
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      brightness: Brightness.light,
      elevation: 0.0,
      titleSpacing: 0.0,
      title: _BackdropTitle(
        listenable: _controller.view,
        onPress: _toggleBackdropLayerVisibility,
        frontTitle: widget.frontTitle,
        backTitle: widget.backTitle,
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
            );
          },
          icon: Icon(
            Icons.search,
            semanticLabel: 'login',
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
            );
          },
          icon: Icon(
            Icons.tune,
            semanticLabel: 'filter',
          ),
        ),
      ],
      backwardsCompatibility: false,
    );
    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(builder: _buildStack),
    );
  }
}

class _FrontLayer extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _FrontLayer({
    Key? key,
    this.onTap,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16.0,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(46.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              height: 40.0,
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
          Expanded(child: child)
        ],
      ),
    );
  }
}
