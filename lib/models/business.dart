class Product {
  final String name;
  final String image;
  Product({required this.name, required this.image});
  factory Product.fromJson(Map<String, dynamic> j) =>
      Product(name: j['name'] ?? '', image: j['image'] ?? '');
}

class Business {
  final String slug;
  final String businessName;
  final String tagline;
  final String ownerName;
  final String establishedYear;
  final String address;
  final String email;
  final String phone1;
  final String phone2;
  final String whatsappNumber;
  final String natureOfBusiness;
  final String aboutUs;
  final String googleMapLink;
  final String vCardDownloadLink;
  final String profileUrl;
  final String specialities;
  final List<Product> products;
  final List<String> galleryImages;
  final String primaryColorHex;
  final int views; // NEW
  final String logoUrl; // NEW logo image URL

  Business(
      {required this.slug,
      required this.businessName,
      required this.tagline,
      required this.ownerName,
      required this.establishedYear,
      required this.address,
      required this.email,
      required this.phone1,
      required this.phone2,
      required this.whatsappNumber,
      required this.natureOfBusiness,
      required this.aboutUs,
      required this.googleMapLink,
      required this.vCardDownloadLink,
      required this.profileUrl,
      required this.specialities,
      required this.products,
      required this.galleryImages,
      required this.primaryColorHex,
      required this.views,
      required this.logoUrl});

  factory Business.fromJson(Map<String, dynamic> j) => Business(
        slug: j['slug'] ?? '',
        businessName: j['businessName'] ?? '',
        tagline: j['tagline'] ?? '',
        ownerName: j['ownerName'] ?? '',
        establishedYear: j['establishedYear'] ?? '',
        address: j['address'] ?? '',
        email: j['email'] ?? '',
        phone1: j['phone1'] ?? '',
        phone2: j['phone2'] ?? '',
        whatsappNumber: j['whatsappNumber'] ?? '',
        natureOfBusiness: j['natureOfBusiness'] ?? '',
        aboutUs: j['aboutUs'] ?? '',
        googleMapLink: j['googleMapLink'] ?? '',
        vCardDownloadLink: j['vCardDownloadLink'] ?? '',
        profileUrl: j['profileUrl'] ?? '',
        specialities: j['specialities'] ?? '',
        products: (j['products'] as List? ?? [])
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
        galleryImages:
            (j['galleryImages'] as List? ?? []).map((e) => '$e').toList(),
        primaryColorHex: (j['theme']?['primaryColor'] as String?) ?? '#FF6A00',
        views: (j['views'] as num?)?.toInt() ?? 0,
        logoUrl: j['logoUrl'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'businessName': businessName,
        'tagline': tagline,
        'ownerName': ownerName,
        'establishedYear': establishedYear,
        'address': address,
        'email': email,
        'phone1': phone1,
        'phone2': phone2,
        'whatsappNumber': whatsappNumber,
        'natureOfBusiness': natureOfBusiness,
        'aboutUs': aboutUs,
        'googleMapLink': googleMapLink,
        'vCardDownloadLink': vCardDownloadLink,
        'profileUrl': profileUrl,
        'specialities': specialities,
        'products': products
            .map((p) => {
                  'name': p.name,
                  'image': p.image,
                })
            .toList(),
        'galleryImages': galleryImages,
        'theme': {'primaryColor': primaryColorHex},
        'views': views,
        'logoUrl': logoUrl,
      };
}
