import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service to launch external applications (YouTube, WhatsApp, Instagram, Contacts, Phone Dialer)
/// and place direct phone calls with graceful fallback.
class AppLauncherService {
  /// Launches YouTube application or falls back to youtube.com
  static Future<bool> launchYouTube() async {
    return _launchWithFallback(
      appUriString: 'vnd.youtube:',
      webUriString: 'https://www.youtube.com',
    );
  }

  /// Launches WhatsApp application or falls back to web WhatsApp
  static Future<bool> launchWhatsApp({String? phoneNumber, String? message}) async {
    final String query = message != null ? '?text=${Uri.encodeComponent(message)}' : '';
    final String cleanPhone = phoneNumber?.replaceAll(RegExp(r'[^\d+]'), '') ?? '';
    
    final appUri = cleanPhone.isNotEmpty
        ? 'whatsapp://send?phone=$cleanPhone$query'
        : 'whatsapp://send$query';
    final webUri = cleanPhone.isNotEmpty
        ? 'https://wa.me/$cleanPhone$query'
        : 'https://api.whatsapp.com/send$query';

    return _launchWithFallback(
      appUriString: appUri,
      webUriString: webUri,
    );
  }

  /// Launches Instagram application or falls back to instagram.com
  static Future<bool> launchInstagram() async {
    return _launchWithFallback(
      appUriString: 'instagram://app',
      webUriString: 'https://www.instagram.com',
    );
  }

  /// Launches system Contacts app or falls back to Google Contacts web
  static Future<bool> launchContacts() async {
    return _launchWithFallback(
      appUriString: 'content://contacts/people/',
      webUriString: 'https://contacts.google.com',
    );
  }

  /// Launches the Phone Dialer
  static Future<bool> launchPhoneDialer() async {
    final uri = Uri.parse('tel:');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching dialer: $e');
    }
    return false;
  }

  /// Initiates a phone call to [phoneNumber]
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s-]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Direct launch attempt for schemes that canLaunchUrl sometimes rejects
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error placing call to $phoneNumber: $e');
      return false;
    }
  }

  static Future<bool> _launchWithFallback({
    required String appUriString,
    required String webUriString,
  }) async {
    final appUri = Uri.parse(appUriString);
    final webUri = Uri.parse(webUriString);

    try {
      if (await canLaunchUrl(appUri)) {
        final success = await launchUrl(appUri, mode: LaunchMode.externalApplication);
        if (success) return true;
      }
    } catch (e) {
      debugPrint('App scheme launch failed ($appUriString): $e');
    }

    try {
      if (await canLaunchUrl(webUri)) {
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Web fallback launch failed ($webUriString): $e');
    }

    return false;
  }
}
