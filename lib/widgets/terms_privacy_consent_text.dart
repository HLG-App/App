import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsPrivacyConsentText extends StatelessWidget {
  const TermsPrivacyConsentText({super.key});

  static final Uri _privacyUri = Uri.parse('https://www.herlonggame.com.au/privacy.html');
  static final Uri _termsUri = Uri.parse('https://www.herlonggame.com.au/terms.html');

  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        debugPrint('Failed to launch url: $uri');
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link. Please try again.')));
      }
    } catch (e) {
      debugPrint('Failed to launch url ($uri): $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant);
    final linkStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: cs.primary, decoration: TextDecoration.underline, decorationColor: cs.primary);

    Widget link(String label, Uri uri) => InkWell(
      onTap: () => _open(context, uri),
      child: Text(label, style: linkStyle),
    );

    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('By continuing you agree to our ', style: textStyle),
            link('Terms', _termsUri),
            Text(' & ', style: textStyle),
            link('Privacy Policy', _privacyUri),
          ],
        ),
      ),
    );
  }
}
