import 'package:flutter/material.dart';
import 'package:hazimetecalendar/utils/colors.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatelessWidget {
  NewsPage({
    super.key,
    this.news_url,
    this.news_title,
    this.news_image,
  });
  final String? news_url;
  final String? news_title;
  final String? news_image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                    width: 100, height: 100, child: Image.network(news_image!)),
                const SizedBox(width: 20),
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      final url = Uri.parse(news_url!);
                      launchUrl(url);
                    },
                    child: Text(
                      news_title!,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NewsArticle extends StatefulWidget {
  final snap;
  const NewsArticle({
    super.key,
    required this.snap,
  });

  @override
  State<NewsArticle> createState() => _NewsArticleState();
}

class _NewsArticleState extends State<NewsArticle> {
  bool isLikeAnimation = false;
  int commentLen = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ).copyWith(right: 0),
              child: NewsPage(
                news_url: widget.snap['news_url'],
                news_title: widget.snap['news_title'],
                news_image: widget.snap['news_image'],
              )),
        ],
      ),
    );
  }
}
