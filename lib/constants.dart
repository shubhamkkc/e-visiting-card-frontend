import 'package:flutter/material.dart';

class AppConstants {
  // API
  static const String apiBaseUrl = "http://192.168.1.34:8080"; // your PC IP
  static const String defaultBusinessSlug = "kanhaiya-lal-sons";

  // Fallback Business Details (used until API loads or if it fails)
  static const String businessName = "Kanhaiya Lal & Sons";
  static const String tagline = "We help you to feel better sound";
  static const String ownerName = "Owner";
  static const String establishedYear = "2015";
  static const String address = "Patna – 800002";
  static const String email = "contact@example.com";
  static const String phone1 = "+91-0000000000";
  static const String phone2 = "";
  static const String whatsappNumber = "+910000000000";
  static const String googleMapLink = "https://maps.google.com";
  static const String vCardDownloadLink = "https://example.com/card.vcf";
  // static const String profileUrl = "https://example.com/profile";
  static const String natureOfBusiness = "Service provider, Event organisers";

  // Specialities as single multi-line string
  static const String specialities = '''
• Ethical business policies
• Affordable pricing
• Reliable services
• Transparent dealings
• Easy payment mode
• Customized solutions
• Best Consultancy
• Use of advanced technology
• We listen,We understand, We provide Solution
• We Provide Pan India services
• A great experience with Happy clients
• Low Price Guarantee with best services
''';

  // Theme fallback
  static const Color primaryColor = Colors.orange;

  // Gallery images used by GallerySection
  static const List<String> galleryImages = [
    'assets/images/gallery1.jpg',
    'assets/images/gallery2.jpg',
    'assets/images/gallery3.jpg',
    'assets/images/gallery4.jpg',
    'assets/images/gallery5.jpg',
    'assets/images/gallery6.jpg',
    'assets/images/gallery7.jpg',
    'assets/images/gallery8.jpg',
    'assets/images/gallery9.jpg',
    'assets/images/gallery10.jpg',
    'assets/images/gallery11.jpg',
    'assets/images/gallery12.jpg',
  ];

  // Initial feedbacks used by FeedbackSection
  static const List<Map<String, dynamic>> feedbacks = [
    {
      "name": "Naresh kumar",
      "date": "November 29, 2024",
      "rating": 5,
      "comment": "Very good"
    },
    {
      "name": "rk singh",
      "date": "November 18, 2024",
      "rating": 4,
      "comment": "good"
    },
    {
      "name": "Sujeetrajdf7516",
      "date": "November 14, 2024",
      "rating": 3,
      "comment": "Good frommens"
    },
    {
      "name": "RK PAWAN KUMAR",
      "date": "December 24, 2022",
      "rating": 5,
      "comment": "Pallavi"
    },
    {
      "name": "Tony paul",
      "date": "October 19, 2021",
      "rating": 4,
      "comment": "Very good"
    },
  ];
}
