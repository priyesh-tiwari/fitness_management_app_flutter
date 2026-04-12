
import 'package:flutter/material.dart';

class Env {
  // Change this ONE line when your IP changes
  static const String baseUrl = 'http://10.134.62.174:5000';

  static const String apiUrl = '$baseUrl/api';
}

abstract class AppTheme {
  // ── Brand ──────────────────────────────────────────────────
  static const primary      = Color(0xFF1B4332);
  static const accentLight  = Color(0xFFD8F3DC);

  // ── Surface & Background ───────────────────────────────────
  static const background   = Color(0xFFF6F7F5);
  static const surface      = Color(0xFFFFFFFF);
  static const border       = Color(0xFFE6EAE6);

  // ── Text ───────────────────────────────────────────────────
  static const textPrimary  = Color(0xFF1A2E1A);
  static const textMuted    = Color(0xFF7A8C7A);

  // ── Semantic ───────────────────────────────────────────────
  static const danger       = Color(0xFFD32F2F);

  // ── Program type badge colours ─────────────────────────────
  static const programTypeColors = <String, Color>{
    'yoga'    : Color(0xFF7B2D8B),
    'gym'     : Color(0xFFB71C1C),
    'cardio'  : Color(0xFFE65100),
    'strength': Color(0xFF1565C0),
    'zumba'   : Color(0xFFAD1457),
  };

  static Color programTypeColor(String type) =>
      programTypeColors[type.toLowerCase()] ?? const Color(0xFF546E6E);

  // ── Notification type → (background, accent) ───────────────
  static const notificationTypeColors = <String, (Color, Color)>{
    'blue'  : (Color(0xFFE3F2FD), Colors.blue),
    'orange': (Color(0xFFFFF3E0), Colors.orange),
    'purple': (Color(0xFFF3E5F5), Colors.purple),
    'indigo': (Color(0xFFE8EAF6), Colors.indigo),
    'green' : (accentLight,       primary),
    'red'   : (Color(0xFFFFEBEE), danger),
    'teal'  : (Color(0xFFE0F2F1), Colors.teal),
  };


  //ACTIVITY SCREEN
  static const kGold        = Color(0xFFFFA000);
  static const kSuccessGreen = Color(0xFF2E7D32);
  static const kGoalMet = Color(0xFF2E7D32);


  //Attendance screen
  static const kAttended = Color(0xFF2E7D32);
  static const kMissed   = Color(0xFFD32F2F);
  static const kUpcoming = Color(0xFF1565C0);

  //subscriptions screens
  static const kPrimary     = Color(0xFF1B4332);
  static const kAccentLight = Color(0xFFD8F3DC);
  static const kBackground  = Color(0xFFF6F7F5);
  static const kSurface     = Color(0xFFFFFFFF);
  static const kTextPrimary = Color(0xFF1A2E1A);
  static const kTextMuted   = Color(0xFF7A8C7A);
  static const kBorder      = Color(0xFFE6EAE6);


}