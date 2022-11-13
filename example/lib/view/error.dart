import 'package:example/view/colors.dart';
import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final Exception error;
  final Function()? onRetry;

  const ErrorState({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
      return Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString()),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: colorWhite,
                    backgroundColor: colorRed
                ),
                onPressed: onRetry ?? () {},
                child: const Text('Retry'),
              )
            ]
        )
    );
  }
}