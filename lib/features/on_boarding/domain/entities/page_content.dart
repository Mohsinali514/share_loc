import 'package:equatable/equatable.dart';
import 'package:share_loc/core/res/media_res.dart';

class PageContent extends Equatable {
  const PageContent({
    required this.image,
    required this.title,
    required this.description,
  });

  const PageContent.first()
      : this(
          image: MediaRes.gather,
          title: 'Create your social circle',
          description:
              'Create your circle to connect with your friends and family',
        );
  const PageContent.second()
      : this(
          image: MediaRes.heartmade,
          title: 'Join any of your friends circle ',
          description:
              'Join circles as many as you want by just one invitation code',
        );
  const PageContent.third()
      : this(
          image: MediaRes.shareloc,
          title: 'Share live location',
          description: 'Share live location with people in your circle',
        );

  final String image;
  final String title;
  final String description;

  @override
  List<Object?> get props => [image, title, description];
}
