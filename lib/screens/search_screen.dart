import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/article.dart';
import '../models/user.dart';
import '../widgets/article_container.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Article> articles = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Qiita Search'),
        ),
        body: Column(
            children: [
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 12,
                    ),
                    child: TextField(
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                        ),
                        decoration: InputDecoration(
                            hintText: '検索ワードを入力してください',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.search),
                        ),
                        onSubmitted: (String keyword) async {
                            setState(() {
                                isLoading = true;
                                errorMessage = '';
                            });
                            try {
                                final results = await searchQiita(keyword);
                                setState(() {
                                    articles = results;
                                    isLoading = false;
                                });
                            } catch (e) {
                                setState(() {
                                    errorMessage = 'エラーが発生しました: $e';
                                    isLoading = false;
                                });
                            }
                        },
                    ),
                ),
                if (isLoading)
                    const CircularProgressIndicator()
                else if (errorMessage.isNotEmpty)
                    Text(errorMessage, style: TextStyle(color: Colors.red))
                else
                    Expanded(
                        child: ListView(
                            children: articles
                                .map((article) => ArticleContainer(article: article))
                                .toList(),
                        )
                    ),
            ],
        ),
    );
  }
}

Future<List<Article>> searchQiita(String keyword) async {
  try {
    final uri = Uri.https('qiita.com', '/api/v2/items', {
      'query': 'title:$keyword',
      'per_page': '10',
    });

    final String token = dotenv.env['QIITA_ACCESS_TOKEN'] ?? '';

    final http.Response res = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      final List<dynamic> body = jsonDecode(res.body);
      return body.map((dynamic json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('APIエラー: ${res.statusCode}');
    }
  } catch (e) {
    throw Exception('ネットワークエラー: $e');
  }
}
