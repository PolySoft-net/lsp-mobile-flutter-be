import 'package:material_ui/material_ui.dart';

/// Model untuk lowongan pekerjaan di Career Expo
class CareerJobItem {
  final String id;
  final String title;
  final String companyName;
  final String companyCategory;
  final String employmentType; // Full Time, Magang, Kontrak, Part Time
  final String workplaceType; // Remote, On Site, Hybrid
  final String location;
  final int salaryMin;
  final int salaryMax;
  final String salaryPeriod;
  final String postedAt;
  final bool isBookmarked;
  final bool isPopular;
  final String category; // Semua, Remote, On Site, Magang
  final String experience;
  final String education;
  final String aboutCompany;
  final List<String> jobDescription;
  final List<String> requirements;
  final List<String> benefits;
  final Color logoBgColor;
  final String logoText;

  const CareerJobItem({
    required this.id,
    required this.title,
    required this.companyName,
    required this.companyCategory,
    required this.employmentType,
    required this.workplaceType,
    required this.location,
    required this.salaryMin,
    required this.salaryMax,
    this.salaryPeriod = 'bulan',
    required this.postedAt,
    this.isBookmarked = false,
    this.isPopular = false,
    required this.category,
    required this.experience,
    required this.education,
    required this.aboutCompany,
    required this.jobDescription,
    required this.requirements,
    required this.benefits,
    this.logoBgColor = const Color(0xFF0284C7),
    this.logoText = '',
  });

  CareerJobItem copyWith({
    String? id,
    String? title,
    String? companyName,
    String? companyCategory,
    String? employmentType,
    String? workplaceType,
    String? location,
    int? salaryMin,
    int? salaryMax,
    String? salaryPeriod,
    String? postedAt,
    bool? isBookmarked,
    bool? isPopular,
    String? category,
    String? experience,
    String? education,
    String? aboutCompany,
    List<String>? jobDescription,
    List<String>? requirements,
    List<String>? benefits,
    Color? logoBgColor,
    String? logoText,
  }) {
    return CareerJobItem(
      id: id ?? this.id,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      companyCategory: companyCategory ?? this.companyCategory,
      employmentType: employmentType ?? this.employmentType,
      workplaceType: workplaceType ?? this.workplaceType,
      location: location ?? this.location,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryPeriod: salaryPeriod ?? this.salaryPeriod,
      postedAt: postedAt ?? this.postedAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isPopular: isPopular ?? this.isPopular,
      category: category ?? this.category,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      aboutCompany: aboutCompany ?? this.aboutCompany,
      jobDescription: jobDescription ?? this.jobDescription,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      logoBgColor: logoBgColor ?? this.logoBgColor,
      logoText: logoText ?? this.logoText,
    );
  }
}

/// Model untuk status lamaran pekerjaan
class CareerApplicationItem {
  final String id;
  final CareerJobItem job;
  final DateTime appliedDate;
  final String status; // 'Terkirim', 'Diproses', 'Wawancara', 'Diterima', 'Ditolak'
  final String? note;

  const CareerApplicationItem({
    required this.id,
    required this.job,
    required this.appliedDate,
    required this.status,
    this.note,
  });
}

/// Mock data lowongan untuk Career Expo UI
class CareerExpoMockData {
  static List<CareerJobItem> getJobs() {
    return [
      const CareerJobItem(
        id: 'job-1',
        title: 'UI/UX Designer',
        companyName: 'PT. Kreatif Digital',
        companyCategory: 'IT Services & Consulting · 51-200 karyawan',
        employmentType: 'Full Time',
        workplaceType: 'Remote',
        location: 'Jakarta',
        salaryMin: 6000000,
        salaryMax: 9000000,
        postedAt: '3 hari yang lalu',
        isBookmarked: false,
        isPopular: true,
        category: 'Remote',
        experience: '1-3 tahun',
        education: 'Min. D3/S1',
        logoBgColor: Color(0xFF0284C7),
        logoText: 'KD',
        aboutCompany:
            'PT. Kreatif Digital adalah perusahaan yang bergerak di bidang teknologi dan desain digital, berfokus pada pengembangan produk digital inovatif untuk berbagai klien di Indonesia.',
        jobDescription: [
          'Membuat desain UI/UX untuk aplikasi dan website',
          'Berkolaborasi dengan tim produk dan developer',
          'Melakukan riset pengguna dan analisis kebutuhan',
          'Merancang wireframe, user flow, dan interactive prototype di Figma',
          'Memastikan konsistensi design system pada seluruh platform',
        ],
        requirements: [
          'Pengalaman minimal 1-3 tahun di bidang UI/UX Design',
          'Menguasai tools desain seperti Figma, FigJam, dan Adobe XD',
          'Memiliki portofolio yang memperlihatkan alur berpikir produk',
          'Memiliki pemahaman sertifikasi kompetensi LSP (Nilai Tambah)',
          'Mampu berkomunikasi dengan baik dan bekerja sama secara remote',
        ],
        benefits: [
          'Gaji kompetitif + Bonus kinerja tahunan',
          'Kerja 100% Remote dengan fleksibilitas jam kerja',
          'Tunjangan koneksi internet & laptop operasional',
          'BPJS Kesehatan & Ketenagakerjaan lengkap',
        ],
      ),
      const CareerJobItem(
        id: 'job-2',
        title: 'UI/UX Designer (Intern)',
        companyName: 'Ruang Digital Studio',
        companyCategory: 'Design & Creative Agency · 11-50 karyawan',
        employmentType: 'Magang',
        workplaceType: 'On Site',
        location: 'Yogyakarta',
        salaryMin: 2000000,
        salaryMax: 3000000,
        postedAt: '5 hari yang lalu',
        isBookmarked: false,
        isPopular: true,
        category: 'Magang',
        experience: 'Fresh Graduate',
        education: 'Min. SMK/D3/S1',
        logoBgColor: Color(0xFF0D9488),
        logoText: 'RD',
        aboutCompany:
            'Ruang Digital Studio adalah agensi kreatif yang berpusat di Yogyakarta, berfokus pada branding, pembuatan sistem desain digital, dan aplikasi mobile modern.',
        jobDescription: [
          'Membantu perancangan antarmuka aplikasi mobile dan web',
          'Membuat aset visual dan ilustrasi micro-interaction',
          'Mendampingi senior designer dalam presentasi konsep ke klien',
          'Membantu usability testing bersama partisipan uji',
        ],
        requirements: [
          'Mahasiswa tingkat akhir atau fresh graduate jurusan Desain/IT/Multimedia',
          'Familiar dengan Figma dan design principles dasar',
          'Mau belajar, proaktif, dan dapat menerima feedback konstruktif',
          'Bersedia magang secara on site di kantor Yogyakarta',
        ],
        benefits: [
          'Uang saku bulanan & sertifikat magang resmi',
          'Mentorship langsung dari praktisi UI/UX berpengalaman',
          'Peluang diangkat menjadi karyawan tetap setelah masa magang',
        ],
      ),
      const CareerJobItem(
        id: 'job-3',
        title: 'UI/UX Designer',
        companyName: 'Nusa Kreatif Teknologi',
        companyCategory: 'Software Development · 50-100 karyawan',
        employmentType: 'Full Time',
        workplaceType: 'On Site',
        location: 'Bandung',
        salaryMin: 5000000,
        salaryMax: 8000000,
        postedAt: '6 hari yang lalu',
        isBookmarked: false,
        isPopular: false,
        category: 'On Site',
        experience: '1-2 tahun',
        education: 'Min. D3/S1',
        logoBgColor: Color(0xFF1E293B),
        logoText: 'NK',
        aboutCompany:
            'Nusa Kreatif Teknologi adalah software house terkemuka di Bandung yang mengembangkan solusi enterprise untuk perbankan, logistik, dan industri retail.',
        jobDescription: [
          'Mengembangkan design guidelines untuk aplikasi web dan desktop',
          'Melakukan benchmarking fitur dan kompetitor',
          'Membangun komponen reusable di Figma Design System',
          'Koordinasi sprint harian bersama Frontend Engineers',
        ],
        requirements: [
          'Pengalaman 1-2 tahun membuat desain aplikasi enterprise',
          'Keahlian solid dalam Figma Auto-Layout, Components, dan Variables',
          'Pemahaman dasar HTML/CSS menjadi nilai tambah',
          'Domisili atau bersedia relokasi ke Bandung',
        ],
        benefits: [
          'BPJS Kesehatan & Ketenagakerjaan',
          'Makan siang harian & snack pantry gratis',
          'Asuransi rawat inap swasta',
        ],
      ),
      const CareerJobItem(
        id: 'job-4',
        title: 'Front End Developer',
        companyName: 'CV. Solusi Digital Inovasi',
        companyCategory: 'Web & Mobile Tech · 20-50 karyawan',
        employmentType: 'Full Time',
        workplaceType: 'On Site',
        location: 'Yogyakarta',
        salaryMin: 6000000,
        salaryMax: 9000000,
        postedAt: '1 minggu yang lalu',
        isBookmarked: false,
        isPopular: true,
        category: 'On Site',
        experience: '2-4 tahun',
        education: 'Min. D3/S1',
        logoBgColor: Color(0xFF2563EB),
        logoText: 'SD',
        aboutCompany:
            'CV. Solusi Digital Inovasi menghadirkan solusi transformasi digital bagi UMKM dan korporasi melalui ekosistem software berbasis cloud yang tangguh.',
        jobDescription: [
          'Mengembangkan antarmuka aplikasi web responsif berbasis Flutter / React',
          'Mengintegrasikan API RESTful dan GraphQL ke dalam client interface',
          'Mengoptimalkan performa rendering halaman dan aksesibilitas',
        ],
        requirements: [
          'Pengalaman minimal 2 tahun dengan Flutter / Vue / React',
          'Memiliki pemahaman state management yang baik (BLoC / Riverpod / Provider)',
          'Sertifikasi Kompetensi Pemrograman Web/Mobile LSP menjadi nilai unggul',
        ],
        benefits: [
          'Gaji kompetitif + insentif proyek',
          'Ruang kerja modern dengan fasilitas hiburan',
          'Dukungan sertifikasi profesional berstandar nasional',
        ],
      ),
      const CareerJobItem(
        id: 'job-5',
        title: 'PT. Inovasi Solusi Digital',
        companyName: 'PT. Inovasi Solusi Digital',
        companyCategory: 'Information Technology · 100-250 karyawan',
        employmentType: 'Full Time',
        workplaceType: 'Remote',
        location: 'Jakarta',
        salaryMin: 7000000,
        salaryMax: 10000000,
        postedAt: '1 minggu yang lalu',
        isBookmarked: false,
        isPopular: false,
        category: 'Remote',
        experience: '2-3 tahun',
        education: 'Min. D3/S1',
        logoBgColor: Color(0xFF0369A1),
        logoText: 'IS',
        aboutCompany:
            'PT. Inovasi Solusi Digital adalah konsultan IT terpercaya yang menyediakan solusi integrasi cloud, kecerdasan buatan, dan keamanan siber.',
        jobDescription: [
          'Merancang antarmuka dashboard monitoring data analitik',
          'Menyusun spesifikasi visual untuk tim engineer',
          'Melakukan evaluasi heuristik terhadap platform yang sudah rilis',
        ],
        requirements: [
          'Pengalaman minimal 2 tahun dalam mendesain B2B Dashboard / SaaS',
          'Terbiasa dengan data visualization dan micro-interactions',
          'Disiplin tinggi untuk pola kerja asynchronous remote',
        ],
        benefits: [
          'Kebijakan Work From Anywhere (WFA)',
          'Tunjangan gadget tahunan',
          'Pelatihan dan sertifikasi berkala',
        ],
      ),
    ];
  }
}
