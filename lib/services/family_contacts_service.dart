import 'package:flutter/material.dart';

/// Model representing a family member or emergency contact.
class FamilyContact {
  final String id;
  final String name;
  final String relationship; // e.g. "Son", "Daughter", "Doctor", "Caregiver"
  final String phoneNumber;
  final Color avatarColor;
  final IconData icon;

  const FamilyContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.avatarColor = const Color(0xFF4C9866),
    this.icon = Icons.person,
  });

  String get displayName {
    if (relationship.trim().isEmpty) return name;
    if (name.toLowerCase().contains(relationship.toLowerCase())) return name;
    return '$name ($relationship)';
  }

  FamilyContact copyWith({
    String? id,
    String? name,
    String? relationship,
    String? phoneNumber,
    Color? avatarColor,
    IconData? icon,
  }) {
    return FamilyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarColor: avatarColor ?? this.avatarColor,
      icon: icon ?? this.icon,
    );
  }
}

/// Service managing family & emergency contacts accessible to both
/// Caregiver (to manage & upload contacts) and Patient (to view & call).
class FamilyContactsService extends ChangeNotifier {
  FamilyContactsService._() {
    _contacts = [
      const FamilyContact(
        id: '1',
        name: 'Rahul',
        relationship: 'Son',
        phoneNumber: '+91 9876543210',
        avatarColor: Color(0xFF005F46),
        icon: Icons.person,
      ),
      const FamilyContact(
        id: '2',
        name: 'Priya',
        relationship: 'Daughter',
        phoneNumber: '+91 9876543211',
        avatarColor: Color(0xFFD64D6E),
        icon: Icons.favorite,
      ),
      const FamilyContact(
        id: '3',
        name: 'Dr. Borah',
        relationship: 'Consultant Physician',
        phoneNumber: '+91 9876543212',
        avatarColor: Color(0xFF0288D1),
        icon: Icons.medical_services,
      ),
    ];
  }

  static final FamilyContactsService instance = FamilyContactsService._();

  late List<FamilyContact> _contacts;

  List<FamilyContact> get contacts => List.unmodifiable(_contacts);

  void addContact({
    required String name,
    required String relationship,
    required String phoneNumber,
  }) {
    final newContact = FamilyContact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      relationship: relationship.trim(),
      phoneNumber: phoneNumber.trim(),
      avatarColor: _pickColorForRelationship(relationship),
      icon: _pickIconForRelationship(relationship),
    );
    _contacts.add(newContact);
    notifyListeners();
  }

  void updateContact(FamilyContact contact) {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _contacts[index] = contact;
      notifyListeners();
    }
  }

  void deleteContact(String id) {
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void resetToDefaults() {
    _contacts = [
      const FamilyContact(
        id: '1',
        name: 'Rahul',
        relationship: 'Son',
        phoneNumber: '+91 9876543210',
        avatarColor: Color(0xFF005F46),
        icon: Icons.person,
      ),
      const FamilyContact(
        id: '2',
        name: 'Priya',
        relationship: 'Daughter',
        phoneNumber: '+91 9876543211',
        avatarColor: Color(0xFFD64D6E),
        icon: Icons.favorite,
      ),
      const FamilyContact(
        id: '3',
        name: 'Dr. Borah',
        relationship: 'Consultant Physician',
        phoneNumber: '+91 9876543212',
        avatarColor: Color(0xFF0288D1),
        icon: Icons.medical_services,
      ),
    ];
    notifyListeners();
  }

  static Color _pickColorForRelationship(String relationship) {
    final rel = relationship.toLowerCase();
    if (rel.contains('son') || rel.contains('brother')) {
      return const Color(0xFF005F46);
    } else if (rel.contains('daughter') || rel.contains('sister')) {
      return const Color(0xFFD64D6E);
    } else if (rel.contains('doctor') || rel.contains('physician')) {
      return const Color(0xFF0288D1);
    } else if (rel.contains('caregiver') || rel.contains('nurse')) {
      return const Color(0xFFFFA000);
    }
    return const Color(0xFF4C9866);
  }

  static IconData _pickIconForRelationship(String relationship) {
    final rel = relationship.toLowerCase();
    if (rel.contains('doctor') || rel.contains('physician')) {
      return Icons.medical_services;
    } else if (rel.contains('daughter') || rel.contains('sister')) {
      return Icons.favorite;
    } else if (rel.contains('caregiver') || rel.contains('nurse')) {
      return Icons.health_and_safety;
    }
    return Icons.person;
  }
}
