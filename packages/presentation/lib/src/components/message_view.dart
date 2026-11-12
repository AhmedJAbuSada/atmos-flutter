import 'package:material_ui/material_ui.dart';

import '../theme/atmos_colors.dart';

/// A button the message offers: its text and what it reports.
typedef MessageAction = ({String title, VoidCallback onPressed});

/// A centred message with up to two actions: for empty, error and "where are you?" states
/// (F-10: every state has a way forward).
class MessageView extends StatelessWidget {
  const MessageView({
    required this.icon,
    required this.message,
    this.title,
    this.action,
    this.secondaryAction,
    super.key,
  });

  final String icon;
  final String? title;
  final String message;
  final MessageAction? action;
  final MessageAction? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final colors = AtmosColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final (action, secondaryAction, title) = (this.action, this.secondaryAction, this.title);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(AtmosSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: Text(icon, style: textTheme.displaySmall)),
            const SizedBox(height: AtmosSpacing.m),
            if (title != null) ...[
              Semantics(
                header: true,
                child: Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
              ),
              const SizedBox(height: AtmosSpacing.s),
            ],
            Text(
              message,
              style: textTheme.bodyLarge?.copyWith(color: colors.secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AtmosSpacing.l),
            if (action != null)
              FilledButton(
                key: const Key('message.action'),
                onPressed: action.onPressed,
                child: Text(action.title),
              ),
            if (secondaryAction != null) ...[
              const SizedBox(height: AtmosSpacing.s),
              TextButton(
                key: const Key('message.secondaryAction'),
                onPressed: secondaryAction.onPressed,
                child: Text(secondaryAction.title),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
