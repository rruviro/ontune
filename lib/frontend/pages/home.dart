import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ontune/frontend/pages/search.dart';
import 'package:ontune/frontend/widget/secret/album_section.dart';
import 'package:page_transition/page_transition.dart';

import '../../backend/bloc/on_tune_bloc.dart';
import '../../backend/services/model/randomized.dart';
import '../widget/floating_music.dart';
import '../widget/main_navigation.dart';
import '../widget/secret/artist_section.dart';
import '../widget/secret/category_selector.dart';
import '../widget/secret/community_seection.dart';
import '../widget/secret/creativity_section.dart';
import '../widget/secret/horizontal_banner.dart';
import '../widget/secret/more_music_like.dart';
import '../widget/secret/music_section.dart';
import '../widget/secret/my_playlist.dart';
import '../widget/secret/new_released_songs.dart';
import '../../resources/schema.dart';

class Home extends StatefulWidget {

  final VoidCallback onToggle;
  final VoidCallback Drawable;

  const Home({Key? key, required this.onToggle, required this.Drawable}) : super(key: key);

  static ValueNotifier<String> updatedWriter = ValueNotifier<String>('');
  static ValueNotifier<String> updatedTitle = ValueNotifier<String>('');
  static ValueNotifier<String> updatedUrl = ValueNotifier<String>('');
  static ValueNotifier<String> updatedIcon = ValueNotifier<String>('');

  @override
  State<Home> createState() => _HomeState();

}

class _HomeState extends State<Home> {

  final GlobalKey<MainWrapperState> drawerOpen = GlobalKey<MainWrapperState>();
  final GlobalKey<FloatingMusicState> floatingMusicKey = GlobalKey<FloatingMusicState>();

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Container(
          width: double.infinity,
          child: Builder(builder: (context) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  child: Center(
                    child: GestureDetector(
                      onTap: widget.Drawable,
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'lib/resources/image/static-profile.jpeg',  // Use Image.asset for local images
                            fit: BoxFit.cover,  // Make sure the image covers the container
                          ),
                        ),
                      ),
                    ),
                  )
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 50,
                    child: Center(
                      child: Container(
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: Search(enableReturn: false),
                                type: PageTransitionType.fade,
                                duration: Duration(milliseconds: 300)
                              )
                            );
                          }, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widgetPricolor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            elevation: 5,
                          ),
                          child: Container(
                            width: double.infinity,
                            child: Center(
                              child: Transform.translate(
                                offset: Offset(-5, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 40,
                                      child: Center(
                                        child: Icon(
                                          size: 17,
                                          Icons.search,
                                          color: Colors.white54,
                                        ),
                                      )
                                    ),
                                    SizedBox(width: 5),
                                    Container(
                                      height: 40,
                                      child: Center(
                                        child: Text(
                                          'Search songs',
                                          style: TextStyle(color: Colors.white54, fontSize: 12.0, fontWeight: FontWeight.w400)
                                        )
                                      )
                                    )
                                  ],
                                )
                              )
                            )
                          )
                        ),
                      )
                    )
                  ),
                )
              ]
            );
          })
        )
      ),
      body: BlocConsumer<OnTuneBloc, OnTuneState>(
        listener: (context, state) {
          if (state is FetchExplorer) {
            print("Fetched explorer list: ${state.explorerList.length}");
          }
        },
        builder: (context, state) {
          if (state is LoadingTune) {
            context.read<OnTuneBloc>().add(LoadTune());
            return const Center(child: CircularProgressIndicator());
          } else if (state is FetchExplorer) {
            
            final List<Randomized> songs = state.explorerList;
            
            List<dynamic> shuffledSongs = List.from(songs)..shuffle();
            int splitPoint = shuffledSongs.length ~/ 2;
            List<dynamic> popularSongs = shuffledSongs.take(splitPoint).toList();
            List<dynamic> recommendedSongs = shuffledSongs.skip(splitPoint).toList();
  
            return ListView(
              children: [
                CategorySelector(),
                CreativitySection(),
                HorizontalBanner(),
                MusicSection(title: 'Popular Today', subtitle: "Today's hits you can't miss", songs: popularSongs, onToggle: widget.onToggle, floatingMusicKey: floatingMusicKey),
                MusicSection(title: 'Matched to your sound taste.', subtitle: "Today's hits you can't miss", songs: recommendedSongs, onToggle: widget.onToggle, floatingMusicKey: floatingMusicKey),
                ArtistSection(title: "Presenting our artists", subtitle: 'Similar to what you listen', listahan: songs),
                MyPlaylist(),
                MoreMusicLike(title: 'More Music like Frank Sinatra', songs: songs, onToggle: widget.onToggle, floatingMusicKey: floatingMusicKey),
                CommunitySection(songs: songs),
                MusicSection(title: "Today's biggest hits", subtitle: "Today's hits you can't miss", songs: recommendedSongs, onToggle: widget.onToggle, floatingMusicKey: floatingMusicKey),
                // NewReleasedSongs(songs: songs),
                AlbumSection(title: 'Artist Album', songs: recommendedSongs, onToggle: widget.onToggle, floatingMusicKey: floatingMusicKey),
              ],
            );
            
          } else if (state is ErrorTune) {
            return Center(
              child: Text(
                "Error: ${state.response}",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return const SizedBox.shrink();
        }
      )
    );
  }
}