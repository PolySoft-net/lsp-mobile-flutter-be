import 'package:flutter_test/flutter_test.dart';
import 'package:lsp_digital_mobile/models/digital_product_models.dart';

void main() {
  group('DigitalProductItem rating fields', () {
    test('parses rating_avg and rating_count correctly', () {
      final json = {
        'id': '10',
        'title': 'Desain Banner',
        'rating_avg': 4.75,
        'rating_count': 23,
      };

      final item = DigitalProductItem.fromJson(json);
      expect(item.id, '10');
      expect(item.title, 'Desain Banner');
      expect(item.ratingAvg, 4.75);
      expect(item.ratingCount, 23);
    });

    test('handles missing or null rating safely', () {
      final json = {
        'id': '11',
        'title': 'Template UI',
      };

      final item = DigitalProductItem.fromJson(json);
      expect(item.ratingAvg, 0.0);
      expect(item.ratingCount, 0);
    });
  });

  group('DigitalProductReviewsData', () {
    test('parses valid reviews response', () {
      final json = {
        'average_rating': 4.8,
        'total_reviews': 12,
        'reviews': [
          {
            'id': 1,
            'product_id': 5,
            'user': {
              'id': 10,
              'name': 'Budi Santoso',
              'photo': 'https://api-domain.com/upload/foto_profil/user1.jpg',
            },
            'rating': 5,
            'comment': 'Template sangat rapi dan mudah digunakan!',
            'images': [
              'https://api-domain.com/upload/digital-products/reviews/sample1.jpg',
            ],
            'created_at': '2026-09-29 10:15:00',
          },
        ],
      };

      final data = DigitalProductReviewsData.fromJson(json);
      expect(data.averageRating, 4.8);
      expect(data.totalReviews, 12);
      expect(data.reviews.length, 1);

      final review = data.reviews.first;
      expect(review.id, 1);
      expect(review.productId, 5);
      expect(review.user.id, 10);
      expect(review.user.name, 'Budi Santoso');
      expect(review.user.photo, 'https://api-domain.com/upload/foto_profil/user1.jpg');
      expect(review.rating, 5);
      expect(review.comment, 'Template sangat rapi dan mudah digunakan!');
      expect(review.images, [
        'https://api-domain.com/upload/digital-products/reviews/sample1.jpg',
      ]);
      expect(review.createdAt, '2026-09-29 10:15:00');
    });

    test('handles empty or malformed fields safely', () {
      final json = <String, dynamic>{
        'average_rating': null,
        'total_reviews': null,
        'reviews': null,
      };

      final data = DigitalProductReviewsData.fromJson(json);
      expect(data.averageRating, 0.0);
      expect(data.totalReviews, 0);
      expect(data.reviews, isEmpty);
    });
  });
}
