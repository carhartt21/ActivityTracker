import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ActivityTracker/constants.dart';
import 'package:ActivityTracker/settings/settings_manager.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';

class Onboarding extends StatelessWidget {
  Onboarding({super.key});

  final List<PageViewModel> listPagesViewModel = [
    PageViewModel(
      titleWidget: const Text(
        'Define your habits',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      image: SvgPicture.asset(
        'assets/images/onboard/1.svg',
        semanticsLabel: 'Empty list',
        width: 250,
      ),
      bodyWidget: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'To better stick to your habits, you can define:',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '1. Cue',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '2. Routine',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '3. Reward',
                    style: TextStyle(fontSize: 18),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    PageViewModel(
      titleWidget: const Text(
        'Log your days',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      image: SvgPicture.asset(
        'assets/images/onboard/2.svg',
        semanticsLabel: 'Empty list',
        width: 250,
      ),
      bodyWidget: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.check,
                    color: ActivityTrackerColors.primary,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Successful',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.close,
                    color: ActivityTrackerColors.red,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Not so successful',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.last_page,
                    color: ActivityTrackerColors.skip,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Skip (does not affect streaks)',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: ActivityTrackerColors.orange,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Comment',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    PageViewModel(
      title: "Observe your progress",
      image: SvgPicture.asset(
        'assets/images/onboard/3.svg',
        semanticsLabel: 'Empty list',
        width: 250,
      ),
      bodyWidget: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'You can track your progress through the calendar view in every habit or on the statistics page.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: listPagesViewModel,
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
      onDone: () {
        if (Provider.of<SettingsManager>(context, listen: false)
            .getSeenOnboarding) {
          Navigator.pop(context);
        } else {
          Provider.of<SettingsManager>(context, listen: false)
              .setSeenOnboarding = true;
        }
      },
      next: const Icon(Icons.arrow_forward),
      showSkipButton: true,
      skip: const Text("Skip"),
    );
  }
}
