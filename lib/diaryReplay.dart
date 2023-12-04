import 'package:capston1/main.dart';
import 'package:capston1/network/api_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'models/Diary.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_sound/flutter_sound.dart' as sound;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class diaryReplay extends StatefulWidget {
  final Diary diary;

  const diaryReplay({super.key, required this.diary});

  @override
  State<diaryReplay> createState() => _writediaryState(diary);
}

List<Diary> diaries = [];

class _writediaryState extends State<diaryReplay> {
  Diary? diary;

  ApiManager apiManager = ApiManager().getApiManager();

  final recorder = sound.FlutterSoundRecorder();
  bool isRecording = false; //녹음 상태
  String audioPath = '';  //녹음중단 시 경로 받아올 변수
  String playAudioPath = '';  //저장할때 받아올 변수 , 재생 시 필요

  _writediaryState(Diary diary) {
    this.diary = diary;
  }

  Future<void> fetchDataFromServer() async {
    try {
      final data = await apiManager.getDiaryShareData();
      setState(() {
        diaries = data!;
      });
    } catch (error) {
      // 에러 제어하는 부분
      print('Error getting share diaries list: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Color(0xFFF8F5EB),
        title: Container(
          child: (() {
            switch (diary?.emotion) {
              case 'smile':
                return Image.asset(
                  'images/emotion/smile.gif',
                  height: 50,
                  width: 50,
                );
              case 'flutter':
                return Image.asset(
                  'images/emotion/flutter.gif',
                  height: 50,
                  width: 50,
                );
              case 'angry':
                return Image.asset(
                  'images/emotion/angry.png',
                  height: 50,
                  width: 50,
                );
              case 'annoying':
                return Image.asset(
                  'images/emotion/annoying.gif',
                  height: 50,
                  width: 50,
                );
              case 'tired':
                return Image.asset(
                  'images/emotion/tired.gif',
                  height: 50,
                  width: 50,
                );
              case 'sad':
                return Image.asset(
                  'images/emotion/sad.gif',
                  height: 50,
                  width: 50,
                );
              case 'calmness':
                return Image.asset(
                  'images/emotion/calmness.gif',
                  height: 50,
                  width: 50,
                );
            }
          })(),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF8F5EB),
        ),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Expanded(
          child: () {
            if (diary!.imagePath.isNotEmpty && diary!.voice == "") {
              return customWidget1(
                  sdate: diary!.date,
                  sdiaryImage: diary!.imagePath,
                  scomment: diary!.content,
                diaryId: diary!.diaryId,
              );
            } else if (diary!.imagePath.isEmpty && diary!.voice == "") {
              return customWidget2(
                sdate: diary!.date,
                scomment: diary!.content,
                diaryId: diary!.diaryId,
              );
            } else if (diary!.imagePath.isEmpty && diary!.voice != "") {
              return customwidget3(
                sdate: diary!.date,
                scomment: diary!.content,
                svoice: diary!.voice,
                diaryId: diary!.diaryId,
              );
            } else if (diary!.imagePath.isNotEmpty && diary!.voice != "") {
              return customwidget4(
                sdate: diary!.date,
                sdiaryImage: diary!.imagePath,
                scomment: diary!.content,
                svoice: diary!.voice,
                diaryId: diary!.diaryId,
              );
            } else {
              // 선택된 이미지에 해당하는 일기가 없을 경우 빈 컨테이너 반환
              return Container();
            }
          }(),
        ),
      ),
    );
  }
}

// 일기 버전 1 - 텍스트 + 사진
class customWidget1 extends StatefulWidget {
  final DateTime sdate;
  final List<String> sdiaryImage;
  final String scomment;
  final int diaryId;

  const customWidget1({
    super.key,
    required this.sdate,
    required this.sdiaryImage,
    required this.scomment,
    required this.diaryId,
  });

  @override
  State<customWidget1> createState() => _customWidget1State(diaryId);
}

class _customWidget1State extends State<customWidget1> {

  int diaryId = 0;

  ApiManager apiManager = ApiManager().getApiManager();

  _customWidget1State(int diaryId) {
    this.diaryId = diaryId;
  }

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Center(
        child: Container(
            width: sizeX * 0.9,
            height: sizeY * 0.8,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(children: [
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      '${widget.sdate.year}년 ${widget.sdate.month}월 ${widget.sdate.day}일',
                      style: TextStyle(
                        fontFamily: 'soojin',
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: 90,
                    ),
                    IconButton(
                        onPressed: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => diaryUpdate(diary: diary,)));
                        },
                      icon: Image.asset('images/main/pencil.png', width: 30, height: 30,),
                    ),
                    IconButton(
                      onPressed: () {
                        apiManager.RemoveDiary(diaryId);
                        print('다이어리 아이디 : ${diaryId}');
                      },
                      icon: Image.asset('images/main/trash.png', width: 30, height: 30,),
                    ),
                  ]),
                ), //날짜
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          child: Container(
                              width: 200,
                              height: 150, // 이미지 높이 조절
                              child: Container(
                                child: PageView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.sdiaryImage.length > 3
                                      ? 3
                                      : widget.sdiaryImage.length,
                                  // 최대 3장까지만 허용
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: Center(
                                        child: Image.asset(
                                            widget.sdiaryImage[index]),
                                      ),
                                    );
                                  },
                                ),
                              )),
                        ),
                        Container(
                            width: 380,
                            padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                            color: Colors.white54,
                            child: Column(
                              children: [
                                Text(
                                  widget.scomment,
                                  style: TextStyle(
                                      fontFamily: 'soojin', fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ), //글
                //수정버튼
              ],
            )),
      ),
    );
  }
}

//글만 있는 거
class customWidget2 extends StatefulWidget {
  final String scomment;
  final DateTime sdate;
  final int diaryId;

  const customWidget2({
    super.key,
    required this.scomment,
    required this.sdate,
    required this.diaryId,
  });

  @override
  State<customWidget2> createState() => _customWidget2State(diaryId);
}

class _customWidget2State extends State<customWidget2> {

  int diaryId = 0;

  ApiManager apiManager = ApiManager().getApiManager();

  _customWidget2State(int diaryId) {
    this.diaryId = diaryId;
  }
  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Center(
        child: Container(
            width: sizeX * 0.9,
            height: sizeY * 0.8,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(children: [
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      '${widget.sdate.year}년 ${widget.sdate.month}월 ${widget.sdate.day}일',
                      style: TextStyle(
                        fontFamily: 'soojin',
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: 90,
                    ),
                     IconButton(
                         onPressed: () {
                         },
                       icon: Image.asset('images/main/pencil.png', width: 30, height: 30,),
                     ),
                    IconButton(
                        onPressed: () {
                          apiManager.RemoveDiary(diaryId);
                          print('다이어리 아이디 : ${diaryId}');
                        },
                        icon: Image.asset('images/main/trash.png', width: 30, height: 30,),
                        ),
                  ]),
                ), //날짜
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                        width: 380,
                        padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                        color: Colors.white54,
                        child: Column(
                          children: [
                            Text(
                              widget.scomment,
                              style:
                                  TextStyle(fontFamily: 'soojin', fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )),
                  ),
                ), //글
                //수정버튼
              ],
            )),
      ),
    );
  }
}

// 일기 버전 3 - 텍스트 + 음성
class customwidget3 extends StatefulWidget {
  final String scomment;
  final String svoice;
  final DateTime sdate;
  final int diaryId;

  const customwidget3({
    super.key,
    required this.scomment,
    required this.svoice,
    required this.sdate,
    required this.diaryId,
  });

  @override
  State<customwidget3> createState() => _customwidget3State(diaryId);
}

class _customwidget3State extends State<customwidget3> {

  int diaryId = 0;

  ApiManager apiManager = ApiManager().getApiManager();

  _customwidget3State(int diaryId) {
    this.diaryId = diaryId;
  }

  //재생에 필요한 것들
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String imagePath = "";

  @override
  void initState() {
    super.initState();
    playAudio();
    setAudio();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
      print("헨들러 isplaying : $isPlaying");
    });

    //재생 파일의 전체 길이를 감지하는 이벤트 핸들러
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    //재생 중인 파일의 현재 위치를 감지하는 이벤트 핸들러
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
      print('Current position: $position');
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }


  Future setAudio() async {
    String url = ' ';
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.setSourceUrl(url);
  }

  Future<void> playAudio() async {
    try {
      if (isPlaying == PlayerState.playing) {
        await audioPlayer.stop(); // 이미 재생 중인 경우 정지시킵니다.
      }

      await audioPlayer.setSourceDeviceFile(widget.svoice);
      print("duration: $duration" );
      await Future.delayed(Duration(seconds: 2));
      print("after wait duration: $duration" );

      setState(() {
        duration = duration;
        isPlaying = true;
      });

      audioPlayer.play;

      print('오디오 재생 시작: ${widget.svoice}');
      print("duration: $duration");
    } catch (e) {
      print("audioPath : ${widget.svoice}");
      print("오디오 재생 중 오류 발생 : $e");
    }
  }

  String formatTime(Duration duration) {
    print("formatTime duration: $duration");

    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    String result = '$minutes:${seconds.toString().padLeft(2, '0')}';

    print("formatTime result: $result");
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Center(
        child: Container(
            width: sizeX * 0.9,
            height: sizeY * 0.8,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(children: [
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      '${widget.sdate.year}년 ${widget.sdate.month}월 ${widget.sdate.day}일',
                      style: TextStyle(
                        fontFamily: 'soojin',
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: 90,
                    ),
                    IconButton(
                         onPressed: () {
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => diaryUpdate(
                    //                   date: DateTime(2023, 11, 24))));
                         },
                      icon: Image.asset('images/main/pencil.png', width: 30, height: 30,),
                    ),
                    IconButton(
                      onPressed: () {
                        apiManager.RemoveDiary(diaryId);
                        print('다이어리 아이디 : ${diaryId}');
                      },
                      icon: Image.asset('images/main/trash.png', width: 30, height: 30,),
                    ),
                  ]),
                ), //날짜
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                          child: Column(
                            children: [
                              SliderTheme(
                                data: SliderThemeData(
                                  inactiveTrackColor: Color(0xFFF8F5EB),
                                ),
                                child: Slider(
                                  min: 0,
                                  max: duration.inSeconds.toDouble(),
                                  value: position.inSeconds.toDouble(),
                                  onChanged: (value) async {
                                    setState(() {
                                      position = Duration(seconds: value.toInt());
                                    });
                                    await audioPlayer.seek(position);
                                    //await audioPlayer.resume();
                                  },
                                  activeColor: Color(0xFF968C83),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Text(
                                      formatTime(position),
                                      style: TextStyle(color: Colors.brown),
                                    ),
                                    SizedBox(width: 20),
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.transparent,
                                      child: IconButton(
                                        padding: EdgeInsets.only(
                                            bottom: 50),
                                        icon: Icon(
                                          isPlaying ? Icons.pause : Icons
                                              .play_arrow,
                                          color: Colors.brown,
                                        ),
                                        iconSize: 25,
                                        onPressed: () async {
                                          print("isplaying 전 : $isPlaying");

                                          if (isPlaying) {  //재생중이면
                                            await audioPlayer.pause(); //멈춤고
                                            setState(() {
                                              isPlaying = false; //상태변경하기..?
                                            });
                                          } else { //멈춘 상태였으면
                                            await playAudio();
                                            await audioPlayer.resume();// 녹음된 오디오 재생
                                          }
                                          print("isplaying 후 : $isPlaying");
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      formatTime(duration),
                                      style: TextStyle(color: Colors.brown),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                            width: 380,
                            padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                            color: Colors.white54,
                            child: Column(
                              children: [
                                Text(
                                  widget.scomment,
                                  style: TextStyle(
                                      fontFamily: 'soojin', fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ), //글
                //수정버튼
              ],
            )),
      ),
    );
  }
}

// 일기 버전4 - 텍스트 + 음성 + 사진
class customwidget4 extends StatefulWidget {
  final List<String> sdiaryImage; // 다이어리 안에 이미지
  final String scomment; // 일기 내용
  final String svoice; // 녹음 기능
  final DateTime sdate;
  final int diaryId;

  const customwidget4({
    super.key,
    required this.sdiaryImage,
    required this.scomment,
    required this.svoice,
    required this.sdate,
    required this.diaryId,
  });

  @override
  State<customwidget4> createState() => _customwidget4State(diaryId);
}

class _customwidget4State extends State<customwidget4> {

  int diaryId = 0;

  ApiManager apiManager = ApiManager().getApiManager();

  _customwidget4State(int diaryId) {
    this.diaryId = diaryId;
  }

  //재생에 필요한 것들
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String imagePath = "";


  @override
  void initState() {
    super.initState();
    playAudio();

    setAudio();

    //재생 상태가 변경될 때마다 상태를 감지하는 이벤트 핸들러
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
      print("헨들러 isplaying : $isPlaying");
    });

    //재생 파일의 전체 길이를 감지하는 이벤트 핸들러
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    //재생 중인 파일의 현재 위치를 감지하는 이벤트 핸들러
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
      print('Current position: $position');
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }


  Future setAudio() async {
    String url = ' ';
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.setSourceUrl(url);
  }

  Future<void> playAudio() async {
    try {
      if (isPlaying == PlayerState.playing) {
        await audioPlayer.stop(); // 이미 재생 중인 경우 정지시킵니다.
      }

      await audioPlayer.setSourceDeviceFile(widget.svoice);
      print("duration: $duration" );
      await Future.delayed(Duration(seconds: 2));
      print("after wait duration: $duration" );

      setState(() {
        duration = duration;
        isPlaying = true;
      });

      audioPlayer.play;

      print('오디오 재생 시작: ${widget.svoice}');
      print("duration: $duration");
    } catch (e) {
      print("audioPath : ${widget.svoice}");
      print("오디오 재생 중 오류 발생 : $e");
    }
  }

  String formatTime(Duration duration) {
    print("formatTime duration: $duration");

    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    String result = '$minutes:${seconds.toString().padLeft(2, '0')}';

    print("formatTime result: $result");
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Center(
        child: Container(
            width: sizeX * 0.9,
            height: sizeY * 0.8,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(children: [
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      '${widget.sdate.year}년 ${widget.sdate.month}월 ${widget.sdate.day}일',
                      style: TextStyle(
                        fontFamily: 'soojin',
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: 90,
                    ),
                    IconButton(
                         onPressed: () {
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => diaryUpdate(
                    //                   date: DateTime(2023, 11, 24))));
                        },
                      icon: Image.asset('images/main/pencil.png', width: 30, height: 30,),
                    ),
                    IconButton(
                      onPressed: () {
                        apiManager.RemoveDiary(diaryId);
                        print('다이어리 아이디 : ${diaryId}');
                      },
                      icon: Image.asset('images/main/trash.png', width: 30, height: 30,),
                    ),
                  ]),
                ), //날짜
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          child: Container(
                              width: 200,
                              height: 150, // 이미지 높이 조절
                              child: Container(
                                child: PageView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.sdiaryImage.length > 3
                                      ? 3
                                      : widget.sdiaryImage.length,
                                  // 최대 3장까지만 허용
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: Center(
                                        child: Image.asset(
                                            widget.sdiaryImage[index]),
                                      ),
                                    );
                                  },
                                ),
                              )),
                        ),
                    Container(
                      padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              inactiveTrackColor: Color(0xFFF8F5EB),
                            ),
                            child: Slider(
                              min: 0,
                              max: duration.inSeconds.toDouble(),
                              value: position.inSeconds.toDouble(),
                              onChanged: (value) async {
                                setState(() {
                                  position = Duration(seconds: value.toInt());
                                });
                                await audioPlayer.seek(position);
                                //await audioPlayer.resume();
                              },
                              activeColor: Color(0xFF968C83),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Text(
                                  formatTime(position),
                                  style: TextStyle(color: Colors.brown),
                                ),
                                SizedBox(width: 20),
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.transparent,
                                  child: IconButton(
                                    padding: EdgeInsets.only(
                                        bottom: 50),
                                    icon: Icon(
                                      isPlaying ? Icons.pause : Icons
                                          .play_arrow,
                                      color: Colors.brown,
                                    ),
                                    iconSize: 25,
                                    onPressed: () async {
                                      print("isplaying 전 : $isPlaying");

                                      if (isPlaying) {  //재생중이면
                                        await audioPlayer.pause(); //멈춤고
                                        setState(() {
                                          isPlaying = false; //상태변경하기..?
                                        });
                                      } else { //멈춘 상태였으면
                                        await playAudio();
                                        await audioPlayer.resume();// 녹음된 오디오 재생
                                      }
                                      print("isplaying 후 : $isPlaying");
                                    },
                                  ),
                                ),
                                SizedBox(width: 20),
                                Text(
                                  formatTime(duration),
                                  style: TextStyle(color: Colors.brown),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                        Container(
                            width: 380,
                            padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                            color: Colors.white54,
                            child: Column(
                              children: [
                                Text(
                                  widget.scomment,
                                  style: TextStyle(
                                      fontFamily: 'soojin', fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ), //글
                //수정버튼
              ],
            )),
      ),
    );
  }
}
