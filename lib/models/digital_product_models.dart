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
  final String? sellerName;
  final List<String>? tags;
  final String? description;

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
    this.sellerName,
    this.tags,
    this.description,
  });
}

const List<DigitalProductItem> digitalProductMockList = [
  DigitalProductItem(
    id: '1',
    title: 'Produk Website',
    price: 'Rp 400.000',
    priceUnit: '/Nego',
    author: 'Adriansyah',
    sellerName: 'Jendela_Website',
    status: 'Open to hire/ Freelance',
    category: 'Jasa',
    thumbnailType: 'iot',
    isFavorite: true,
    tags: ['#Online', '#Produk', '#Website', '#Design'],
    description:
        'website ini hanya berupa desain prototype saja. Website ini cocok untuk produk apa saja. Pengerjaan membutuhkan sekitar 2 bulan dan secara online atau daring..',
  ),
  DigitalProductItem(
    id: '2',
    title: 'Tamplate Aplikasi E-commers',
    price: 'Rp 50.000',
    priceUnit: '/Nego',
    author: 'Adriansyah',
    sellerName: 'Jendela_Website',
    status: 'Open to hire/ Freelance',
    category: 'Produk',
    thumbnailType: 'ecom',
    isFavorite: true,
    tags: ['#Online', '#Produk', '#Website', '#Design'],
    description:
        'Template aplikasi e-commerce modern berbasis Flutter dan backend API yang siap dipakai untuk berjualan online secara instan.',
  ),
  DigitalProductItem(
    id: '3',
    title: 'Jasa Pembuatan Website Company Profil',
    price: 'Rp 400.000',
    priceUnit: '/Nego',
    author: 'Adriansyah',
    sellerName: 'Jendela_Website',
    status: 'Open to hire/ Freelance',
    category: 'Jasa',
    thumbnailType: 'iot',
    isFavorite: true,
    tags: ['#Online', '#Produk', '#Website', '#Design'],
    description:
        'website ini hanya berupa desain prototype saja. Website ini cocok untuk produk apa saja. Pengerjaan membutuhkan sekitar 2 bulan dan secara online atau daring..',
  ),
  DigitalProductItem(
    id: '4',
    title: 'Tamplate Aplikasi E-commers',
    price: 'Rp 50.000',
    priceUnit: '/Nego',
    author: 'Adriansyah',
    sellerName: 'Jendela_Website',
    status: 'Open to hire/ Freelance',
    category: 'Produk',
    thumbnailType: 'ecom',
    isFavorite: true,
    tags: ['#Online', '#Produk', '#Website', '#Design'],
    description:
        'Template aplikasi e-commerce modern berbasis Flutter dan backend API yang siap dipakai untuk berjualan online secara instan.',
  ),
  DigitalProductItem(
    id: '5',
    title: 'Jasa Pembuatan Website Company Profil',
    price: 'Rp 400.000',
    priceUnit: '/Nego',
    author: 'Adriansyah',
    sellerName: 'Jendela_Website',
    status: 'Open to hire/ Freelance',
    category: 'Jasa',
    thumbnailType: 'iot',
    isFavorite: true,
    tags: ['#Online', '#Produk', '#Website', '#Design'],
    description:
        'website ini hanya berupa desain prototype saja. Website ini cocok untuk produk apa saja. Pengerjaan membutuhkan sekitar 2 bulan dan secara online atau daring..',
  ),
  DigitalProductItem(
    id: '6',
    title: 'Tamplate Aplikasi E-commers',
    price: 'Rp 50.000',
    priceUnit: '/Nego',
    author: 'Adriansyah',
    sellerName: 'Jendela_Website',
    status: 'Open to hire/ Freelance',
    category: 'Produk',
    thumbnailType: 'ecom',
    isFavorite: true,
    tags: ['#Online', '#Produk', '#Website', '#Design'],
    description:
        'Template aplikasi e-commerce modern berbasis Flutter dan backend API yang siap dipakai untuk berjualan online secara instan.',
  ),
  DigitalProductItem(
    id: '7',
    title: 'Jasa Pembuatan Website Company Profil',
    price: 'Rp 400.000',
    priceUnit: '/Nego',
    author: 'Adriansyah',
    sellerName: 'Jendela_Website',
    status: 'Open to hire/ Freelance',
    category: 'Online',
    thumbnailType: 'iot',
    isFavorite: true,
    tags: ['#Online', '#Produk', '#Website', '#Design'],
    description:
        'website ini hanya berupa desain prototype saja. Website ini cocok untuk produk apa saja. Pengerjaan membutuhkan sekitar 2 bulan dan secara online atau daring..',
  ),
  DigitalProductItem(
    id: '8',
    title: 'Tamplate Aplikasi E-commers',
    price: 'Rp 50.000',
    priceUnit: '/Nego',
    author: 'Adriansyah',
    sellerName: 'Jendela_Website',
    status: 'Open to hire/ Freelance',
    category: 'Offline',
    thumbnailType: 'ecom',
    isFavorite: true,
    tags: ['#Online', '#Produk', '#Website', '#Design'],
    description:
        'Template aplikasi e-commerce modern berbasis Flutter dan backend API yang siap dipakai untuk berjualan online secara instan.',
  ),
];

