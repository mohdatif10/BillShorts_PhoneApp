import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bill_shorts/pages/hyperlink.dart' as hyperlink;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';



class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isButtonVisible = true;
  late String articleTitle = '';
  late String articlePrecis = '';
  late String articleImage = '';

  final videoURL = "https://www.youtube.com/watch?v=YMx8Bbev6T4";

  late YoutubePlayerController _controller;

  static final customCacheManager = CacheManager(
    Config(
      'customCacheKey',
      stalePeriod: const Duration(days: 10),
      maxNrOfCacheObjects: 400,
    ),
  );


  late SharedPreferences _prefs;
  static const int maxCachedArticles = 150;
  List<Map<String, String>> cachedArticles = [];

  void _toggleButtonVisibility() {
    setState(() {
      _isButtonVisible = !_isButtonVisible;
    });
  }

  @override
  void initState() {
    fetchArticles();
    initializeSharedPreferences();

    final videoID=YoutubePlayer.convertUrlToId(videoURL);

    _controller=YoutubePlayerController(
      initialVideoId: videoID!,
    );
    super.initState();
  }

  Future<void> initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    loadCachedArticles();
  }

  void loadCachedArticles() {
    List<String>? cachedArticlesList = _prefs.getStringList('cached_articles');
    if (cachedArticlesList != null) {
      cachedArticles = cachedArticlesList
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .cast<Map<String, String>>()
          .take(maxCachedArticles)
          .toList();


      for (var article in cachedArticles) {
        print('Cached Article: $article');
      }
      print('length of cached articles: ${cachedArticles.length}');

      //try printing
      //firebase pulling only - up arrow
    }
  }

  Future<void> saveCachedArticles() async {
    List<String> serializedArticles =
    cachedArticles.map((item) => json.encode(item)).toList();
    await _prefs.setStringList('cached_articles', serializedArticles);
  }

  List<Map<String, String>> articles = [];
  int currentIndex = 0; // Declare and initialize currentIndex here
  int jsonDumpLength = 0; // Variable to store the length of the JSON dump
  int trackingIndex = 0;

  Future<void> fetchArticles() async {
    var url = Uri.parse('http://127.0.0.1:5000/'); // FLASK API endpoint

    // Clear the image cache before fetching new articles
    // Clear the image cache before fetching new articles
    imageCache.clear();

    try {
      var response = await http.get(url);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData is List<dynamic>) {
          setState(() {
            articles = jsonData.reversed
                .map((item) {
              if (item is Map<String, dynamic>) {
                articleImage = item['image'].toString();
                return {
                  'id': item['id'].toString(),
                  'title': item['title'].toString(),
                  'content': item['content'].toString(),
                  'image': item['image_url'].toString(),
                  'dest_link': item['dest_link'].toString(),
                };
              } else {
                return {
                  'id': '',
                  'title': '',
                  'content': '',
                  'image': '',
                  'dest_link': '',
                };
              }
            })
                .toList();
            jsonDumpLength =
                articles.length; // Update the jsonDumpLength variable
          });
        } else if (jsonData is Map<String, dynamic>) {
          setState(() {
            articles = [
              {
                'id': jsonData['id'].toString(),
                'title': jsonData['title'].toString(),
                'content': jsonData['content'].toString(),
                'image': jsonData['image_url'].toString(),
                'dest_link': jsonData['dest_link'].toString(),
              }
            ];
            jsonDumpLength =
                articles.length; // Update the jsonDumpLength variable
          });
        }
      } else {
        // Request failed
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      // Request error
      print('Request error: $error');
    }

    print("jsonDumpLength $jsonDumpLength");
    trackingIndex = jsonDumpLength;
    print("trackingIndex $trackingIndex");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _toggleButtonVisibility,
        onVerticalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! > 0) {
            // Swipe down
            if (trackingIndex == jsonDumpLength) {
              return;
            };
            setState(() {
              articles.insert(0, articles.removeLast());
              trackingIndex = trackingIndex + 1;
              print("trackingIndex $trackingIndex");
            });
          } else if (details.primaryVelocity! < 0) {
            if (trackingIndex == 1 ||
                trackingIndex == jsonDumpLength - maxCachedArticles + 1) {
              return;
            };
            // Swipe up
            setState(() {
              articles.add(articles.removeAt(0));
              trackingIndex = trackingIndex - 1;
              print("trackingIndex $trackingIndex");
            });
          }
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! < 0) {
            // Swipe left
            String destUrl = articles[currentIndex]['dest_link'] ?? '';
            if (destUrl.isNotEmpty && Uri.tryParse(destUrl) != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      hyperlink.HyperlinkPage(destinationUrl: destUrl),
                ),
              );
            }
          }
        },
        child: PageView.builder(
          itemCount: articles.length,
          itemBuilder: (context, index) {
            currentIndex = index;
            var article = articles[index];
            var nextArticle = articles[(index + 1) % articles.length];

            Widget mediaWidget = article['image'] != null
                ? CachedNetworkImage(
              cacheManager: customCacheManager,
              key: UniqueKey(),
              imageUrl: article['image'] ?? '',
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            )
                : YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator:true,
              bottomActions: [
                CurrentPosition(),
                ProgressBar(
                  isExpanded: true,
                  colors: const ProgressBarColors(
                    playedColor: Colors.red,
                    handleColor: Colors.amberAccent,
                  ),
                ),
                const PlaybackSpeedButton(),
              ],
            );

            print("article['image']: ${article['image']}");

            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height / 3,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      color: Color(0xFF639843),
                      child: mediaWidget,
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.grey[100],
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article['title'] ?? '',
                              style: TextStyle(
                                fontSize: 24.0,
                                color: Colors.black,
                                fontFamily: "NoticiaText-Regular.ttf",
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              article['content'] ?? '',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: Visibility(
                    visible: _isButtonVisible,
                    child: FloatingActionButton(
                      onPressed: () {
                        fetchArticles();
                      },
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                        ),
                      ),
                      child: Container(
                        width: 45.24,
                        height: 55.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                          ),
                          color: Colors.black,
                        ),
                        child: Icon(
                          Icons.arrow_upward,
                          color: Color(0xFF5578F2),
                          size: 40.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.grey[500],
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      nextArticle['title'] ?? '',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String extractVideoId(String videoUrl) {
  final regExp = RegExp(
    r'^https?:(?:www\.)?youtu(?:\.be|be\.com)(?:watch\?v=|embed|v|vi?|u\w|playlist\?|watch\?.+&v=)([^#&?\n]+)',
  );
  final match = regExp.firstMatch(videoUrl);
  return match?.group(1) ?? '';
}