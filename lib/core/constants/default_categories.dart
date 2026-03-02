class DefaultCategory {
  final String name;
  final String icon;

  const DefaultCategory({required this.name, required this.icon});
}

const List<DefaultCategory> defaultCategories = [
  DefaultCategory(name: 'Work', icon: '💼'),
  DefaultCategory(name: 'Education', icon: '🎓'),
  DefaultCategory(name: 'Personal', icon: '🏠'),
  DefaultCategory(name: 'Health', icon: '🏋️'),
  DefaultCategory(name: 'Travel', icon: '✈️'),
];
