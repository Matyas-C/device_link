import 'package:flutter/material.dart';

class CommonScrollPage extends StatelessWidget {
  final Widget child;

  const CommonScrollPage({
    super.key,
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: child,
              ),
            ),
          ),
        ),
    );
  }
}