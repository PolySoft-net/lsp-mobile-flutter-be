import '../../utils/json_helper.dart';

class AsesiPortofolioItem {
  final int id;
  final String judul;
  final String tipe; // "link", "dokumen", "gambar"
  final String bukti; // URL file lengkap atau tautan web
  final String namaFile;
  final String extension;
  final String tanggal;
  final String deskripsi;
  final String fileSize;
  final String createdWhen;

  const AsesiPortofolioItem({
    required this.id,
    required this.judul,
    required this.tipe,
    required this.bukti,
    required this.namaFile,
    required this.extension,
    required this.tanggal,
    required this.deskripsi,
    this.fileSize = '',
    this.createdWhen = '',
  });

  bool get isLink => tipe == 'link' || extension == 'link';

  bool get isGambar =>
      tipe == 'gambar' ||
      ['jpg', 'jpeg', 'png', 'webp'].contains(extension.toLowerCase());

  bool get isDokumen => !isLink && !isGambar;

  factory AsesiPortofolioItem.fromJson(Map<String, dynamic> json) {
    return AsesiPortofolioItem(
      id: JsonHelper.asInt(json['id']),
      judul: json['judul']?.toString() ?? 'Portofolio',
      tipe: json['tipe']?.toString() ?? 'dokumen',
      bukti: json['bukti']?.toString() ?? '',
      namaFile: json['nama_file']?.toString() ?? '',
      extension: json['extension']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      fileSize: json['file_size']?.toString() ?? '',
      createdWhen: json['created_when']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'tipe': tipe,
      'bukti': bukti,
      'nama_file': namaFile,
      'extension': extension,
      'tanggal': tanggal,
      'deskripsi': deskripsi,
      'file_size': fileSize,
      'created_when': createdWhen,
    };
  }
}
