import 'package:flutter/material.dart';

import 'memory_hunt_widgets.dart';

/// Level configuration model for Memory Hunt.
class MemoryHuntLevelData {
  final int levelNumber;
  final List<MemoryHuntItem> memorizeItems;
  final List<MemoryHuntItem> answerItems;
  final Set<String> targetIds;
  final List<String> hints;

  const MemoryHuntLevelData({
    required this.levelNumber,
    required this.memorizeItems,
    required this.answerItems,
    required this.targetIds,
    required this.hints,
  });

  int get targetCount => memorizeItems.length;
}

/// Catalog of all memory items with asset path and fallback icons.
class MemoryHuntCatalog {
  MemoryHuntCatalog._();

  static const MemoryHuntItem apple = MemoryHuntItem(
    id: 'apple',
    label: 'Apple',
    assetPath: 'assets/images/memory/apple.png',
    fallbackIcon: Icons.apple,
  );

  static const MemoryHuntItem book = MemoryHuntItem(
    id: 'book',
    label: 'Book',
    assetPath: 'assets/images/memory/book.png',
    fallbackIcon: Icons.menu_book,
  );

  static const MemoryHuntItem ball = MemoryHuntItem(
    id: 'ball',
    label: 'Ball',
    assetPath: 'assets/images/memory/ball.png',
    fallbackIcon: Icons.sports_baseball,
  );

  static const MemoryHuntItem cup = MemoryHuntItem(
    id: 'cup',
    label: 'Cup',
    assetPath: 'assets/images/memory/cup.png',
    fallbackIcon: Icons.local_cafe,
  );

  static const MemoryHuntItem car = MemoryHuntItem(
    id: 'car',
    label: 'Car',
    assetPath: 'assets/images/memory/car.png',
    fallbackIcon: Icons.directions_car,
  );

  static const MemoryHuntItem dog = MemoryHuntItem(
    id: 'dog',
    label: 'Dog',
    assetPath: 'assets/images/memory/dog.png',
    fallbackIcon: Icons.pets,
  );

  static const MemoryHuntItem clock = MemoryHuntItem(
    id: 'clock',
    label: 'Clock',
    assetPath: 'assets/images/memory/clock.png',
    fallbackIcon: Icons.access_time_filled,
  );

  static const MemoryHuntItem flower = MemoryHuntItem(
    id: 'flower',
    label: 'Flower',
    assetPath: 'assets/images/memory/flower.png',
    fallbackIcon: Icons.local_florist,
  );

  static const MemoryHuntItem house = MemoryHuntItem(
    id: 'house',
    label: 'House',
    assetPath: 'assets/images/memory/house.png',
    fallbackIcon: Icons.home,
  );

  static const MemoryHuntItem tree = MemoryHuntItem(
    id: 'tree',
    label: 'Tree',
    assetPath: 'assets/images/memory/tree.png',
    fallbackIcon: Icons.park,
  );

  static const MemoryHuntItem sun = MemoryHuntItem(
    id: 'sun',
    label: 'Sun',
    assetPath: 'assets/images/memory/sun.png',
    fallbackIcon: Icons.wb_sunny,
  );

  static const MemoryHuntItem star = MemoryHuntItem(
    id: 'star',
    label: 'Star',
    assetPath: 'assets/images/memory/star.png',
    fallbackIcon: Icons.star,
  );

  static const MemoryHuntItem bird = MemoryHuntItem(
    id: 'bird',
    label: 'Bird',
    assetPath: 'assets/images/memory/bird.png',
    fallbackIcon: Icons.flutter_dash,
  );

  static const MemoryHuntItem fish = MemoryHuntItem(
    id: 'fish',
    label: 'Fish',
    assetPath: 'assets/images/memory/fish.png',
    fallbackIcon: Icons.phishing,
  );

  static const MemoryHuntItem hat = MemoryHuntItem(
    id: 'hat',
    label: 'Hat',
    assetPath: 'assets/images/memory/hat.png',
    fallbackIcon: Icons.face,
  );

  static const MemoryHuntItem key = MemoryHuntItem(
    id: 'key',
    label: 'Key',
    assetPath: 'assets/images/memory/key.png',
    fallbackIcon: Icons.vpn_key,
  );

  static const MemoryHuntItem chair = MemoryHuntItem(
    id: 'chair',
    label: 'Chair',
    assetPath: 'assets/images/memory/chair.png',
    fallbackIcon: Icons.chair,
  );

  static const MemoryHuntItem boat = MemoryHuntItem(
    id: 'boat',
    label: 'Boat',
    assetPath: 'assets/images/memory/boat.png',
    fallbackIcon: Icons.directions_boat,
  );

  static const MemoryHuntItem train = MemoryHuntItem(
    id: 'train',
    label: 'Train',
    assetPath: 'assets/images/memory/train.png',
    fallbackIcon: Icons.train,
  );

  static const MemoryHuntItem umbrella = MemoryHuntItem(
    id: 'umbrella',
    label: 'Umbrella',
    assetPath: 'assets/images/memory/umbrella.png',
    fallbackIcon: Icons.beach_access,
  );

  static const MemoryHuntItem camera = MemoryHuntItem(
    id: 'camera',
    label: 'Camera',
    assetPath: 'assets/images/memory/camera.png',
    fallbackIcon: Icons.camera_alt,
  );

  static const MemoryHuntItem guitar = MemoryHuntItem(
    id: 'guitar',
    label: 'Guitar',
    assetPath: 'assets/images/memory/guitar.png',
    fallbackIcon: Icons.music_note,
  );

  static const MemoryHuntItem shoe = MemoryHuntItem(
    id: 'shoe',
    label: 'Shoe',
    assetPath: 'assets/images/memory/shoe.png',
    fallbackIcon: Icons.do_not_step,
  );

  static const MemoryHuntItem phone = MemoryHuntItem(
    id: 'phone',
    label: 'Phone',
    assetPath: 'assets/images/memory/phone.png',
    fallbackIcon: Icons.phone_iphone,
  );

  static const MemoryHuntItem bicycle = MemoryHuntItem(
    id: 'bicycle',
    label: 'Bicycle',
    assetPath: 'assets/images/memory/bicycle.png',
    fallbackIcon: Icons.pedal_bike,
  );

  static const MemoryHuntItem lamp = MemoryHuntItem(
    id: 'lamp',
    label: 'Lamp',
    assetPath: 'assets/images/memory/lamp.png',
    fallbackIcon: Icons.light,
  );

  /// All 5 predefined levels.
  static final List<MemoryHuntLevelData> levels = [
    // Level 1: 3 images
    MemoryHuntLevelData(
      levelNumber: 1,
      memorizeItems: const [apple, book, ball],
      answerItems: const [apple, book, ball, dog, car, cup],
      targetIds: const {'apple', 'book', 'ball'},
      hints: const [
        'One of the objects is something you read with pages (Book).',
        'One of the objects is a healthy, sweet red fruit (Apple).',
        'The third object is round and used in outdoor games (Ball).',
      ],
    ),

    // Level 2: 5 images
    MemoryHuntLevelData(
      levelNumber: 2,
      memorizeItems: const [clock, flower, house, tree, sun],
      answerItems: const [clock, flower, house, tree, sun, car, cup, apple, ball],
      targetIds: const {'clock', 'flower', 'house', 'tree', 'sun'},
      hints: const [
        'Look for two items in the sky and day: the bright Sun and a ticking Clock.',
        'Look for two living nature items: a colorful Flower and a leafy green Tree.',
        'One of the items is a cozy House where people live.',
      ],
    ),

    // Level 3: 7 images
    MemoryHuntLevelData(
      levelNumber: 3,
      memorizeItems: const [star, bird, fish, hat, key, chair, boat],
      answerItems: const [
        star,
        bird,
        fish,
        hat,
        key,
        chair,
        boat,
        clock,
        flower,
        book,
        sun,
      ],
      targetIds: const {'star', 'bird', 'fish', 'hat', 'key', 'chair', 'boat'},
      hints: const [
        'Look for creatures in sky and water: a singing Bird and swimming Fish.',
        'Look for a glowing Star in the night sky and a sailing Boat on the water.',
        'Look for everyday essentials: a Hat to wear, a Key for doors, and a Chair to sit.',
      ],
    ),

    // Level 4: 8 images
    MemoryHuntLevelData(
      levelNumber: 4,
      memorizeItems: const [
        train,
        umbrella,
        camera,
        guitar,
        shoe,
        phone,
        bicycle,
        lamp,
      ],
      answerItems: const [
        train,
        umbrella,
        camera,
        guitar,
        shoe,
        phone,
        bicycle,
        lamp,
        star,
        boat,
        tree,
        house,
      ],
      targetIds: const {
        'train',
        'umbrella',
        'camera',
        'guitar',
        'shoe',
        'phone',
        'bicycle',
        'lamp',
      },
      hints: const [
        'Travel vehicles: a locomotive Train on tracks and a two-wheeled Bicycle.',
        'Music and photos: a stringed Guitar, a Camera, and an indoor Lamp.',
        'Daily items: an Umbrella for rain, a Shoe for walking, and a Phone for calls.',
      ],
    ),

    // Level 5: 10 images
    MemoryHuntLevelData(
      levelNumber: 5,
      memorizeItems: const [
        apple,
        clock,
        sun,
        tree,
        star,
        camera,
        guitar,
        umbrella,
        bird,
        train,
      ],
      answerItems: const [
        apple,
        clock,
        sun,
        tree,
        star,
        camera,
        guitar,
        umbrella,
        bird,
        train,
        shoe,
        boat,
        ball,
        cup,
        house,
      ],
      targetIds: const {
        'apple',
        'clock',
        'sun',
        'tree',
        'star',
        'camera',
        'guitar',
        'umbrella',
        'bird',
        'train',
      },
      hints: const [
        'Nature and sky: shining Sun, night Star, green Tree, and soaring Bird.',
        'Entertainment and travel: a musical Guitar, a camera to take pictures, and a Train.',
        'Everyday essentials: a tasty Apple, a ticking Clock, and a rain Umbrella.',
      ],
    ),
  ];
}
