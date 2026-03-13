import 'package:dio/dio.dart';
import 'package:dio_web_adapter/dio_web_adapter.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MovieApp());

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.red,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> Filmler = [
    {'tr': 'Esaretin Bedeli', 'en': 'The Shawshank Redemption'},
    {'tr': 'Baba', 'en': 'The Godfather'},
    {'tr': 'Baba 2', 'en': 'The Godfather Part II'},
    {'tr': 'Kara Şövalye', 'en': 'The Dark Knight'},
    {'tr': 'Inception', 'en': 'Inception'},
    {'tr': '12 Kızgın Adam', 'en': '12 Angry Men'},
    {'tr': 'Schindler\'in Listesi', 'en': 'Schindler\'s List'},
    {
      'tr': 'LOTR: Kralın Dönüşü',
      'en': 'The Lord of the Rings: The Return of the King',
    },
    {'tr': 'Pulp Fiction', 'en': 'Pulp Fiction'},
    {'tr': 'İyi, Kötü, Çirkin', 'en': 'The Good, the Bad and the Ugly'},
  ];
  String? secilenfilm;

  void SelectedMovie(Map<String, String> film) {
    setState(() {
      secilenfilm = film['tr'];
    });

    final veri = tumFilmVerileri[film['en']];

    String aramaMetni = '';

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Image.network(
                veri!['Poster'],
                height: 300,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      veri['Title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text('IMDb: ${veri['imdbRating']}'),
                    Text('Yıl: ${veri['Year']}'),
                    Text('Yönetmen: ${veri['Director']}'),
                    const SizedBox(height: 8),
                    Text(veri['Plot'], textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // uygulama açılınca tüm filmler için API'ye istek at
    for (final film in Filmler) {
      getfilm(film['en']!);
    }
  }

  Map<String, dynamic> tumFilmVerileri = {};

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.omdbapi.com/',
      queryParameters: {"apikey": '1eda5603'},
    ),
  )..httpClientAdapter = BrowserHttpClientAdapter();

  Future getfilm(String enIsim) async {
    try {
      final response = await dio.get("", queryParameters: {"t": enIsim});
      setState(() {
        tumFilmVerileri[enIsim] =
            response.data; // hangi filme ait olduğunu biliyoruz
      });
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text(
          "Movie App",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              showSearch(
                context: context,
                delegate: FilmArama(Filmler, tumFilmVerileri),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                final film = Filmler[index];
                final veri = tumFilmVerileri[film['en']];
                return GestureDetector(
                  onTap: () => SelectedMovie(film),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Expanded(
                          child: veri != null
                              ? Image.network(
                                  veri['Poster'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : const Icon(
                                  Icons.movie,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            film['tr']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: Filmler.length,
            ),
          ),
        ],
      ),
    );
  }
}

class FilmArama extends SearchDelegate {
  final List<Map<String, String>> filmler;
  final Map<String, dynamic> tumFilmVerileri;

  FilmArama(this.filmler, this.tumFilmVerileri);

  @override
  List<Widget> buildActions(BuildContext context) {
    // sağdaki X butonu — arama metnini temizler
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // soldaki geri butonu
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildFilmListesi();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // yazdıkça burası çalışır
    return _buildFilmListesi();
  }

  Widget _buildFilmListesi() {
    final filtrelenmis = filmler.where((film) {
      return film['tr']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filtrelenmis.length,
      itemBuilder: (context, index) {
        final film = filtrelenmis[index];
        final veri = tumFilmVerileri[film['en']];
        return ListTile(
          onTap: () {
            close(context, null); // önce arama ekranını kapat
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.network(
                        veri!['Poster'],
                        height: 300,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              veri['Title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text('IMDb: ${veri['imdbRating']}'),
                            Text('Yıl: ${veri['Year']}'),
                            Text('Yönetmen: ${veri['Director']}'),
                            const SizedBox(height: 8),
                            Text(veri['Plot'], textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          leading: veri != null
              ? Image.network(veri['Poster'], width: 50, fit: BoxFit.cover)
              : const Icon(Icons.movie),
          title: Text(film['tr']!),
          subtitle: veri != null ? Text('IMDb: ${veri['imdbRating']}') : null,
        );
      },
    );
  }
}
