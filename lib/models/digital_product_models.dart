class DigitalProductItem {
  final String id;
  final String title;
  final String price;
  final String priceUnit;
  final String author;
  final String status;
  final String category; // 'Online', 'Offline', 'Jasa', 'Produk'
  final String thumbnailType; // 'iot', 'ecom', etc.
  final bool isFavorite;

  const DigitalProductItem({
    required this.id,
    required this.title,
    required this.price,
    this.priceUnit = '/Nego',
    required this.author,
    this.status = 'Open to hire/ Freelance',
    required this.category,
    this.thumbnailType = 'iot',
    this.isFavorite = false,
  });
}

