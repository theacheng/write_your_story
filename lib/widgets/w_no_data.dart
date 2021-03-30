import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:write_story/constants/config_constant.dart';

class WNoData extends StatelessWidget {
  const WNoData({
    Key? key,
    required this.monthName,
  }) : super(key: key);

  final String monthName;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrant) {
        bool tablet = constrant.maxWidth > constrant.maxHeight;
        return Center(
          child: Container(
            width: constrant.maxWidth / 2,
            margin: EdgeInsets.only(bottom: ConfigConstant.margin2),
            child: Text(
              tr(
                "msg.story.empty",
                namedArgs: {'MONTH_NAME': monthName},
              ),
              textAlign: tablet ? TextAlign.start : TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.5),
                  ),
            ),
          ),
        );
      },
    );
  }
}
