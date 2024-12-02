extension StringCasingExtension on String {
  String get capitalizeFirstOfEach => this.split(' ')
      .map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : '')
      .join(' ');
}
