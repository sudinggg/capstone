import 'package:capston1/main.dart';
import 'package:capston1/network/api_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sound/flutter_sound.dart' as sound;
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

final String now = DateTime.now().toString();
String formattedDate = DateFormat('yyyy년 MM월 dd일').format(DateTime.now());

class writediary extends StatefulWidget {
  const writediary({super.key, required this.emotion});

  final String emotion;

  @override
  State<writediary> createState() => _writediaryState();
}

final picker = ImagePicker();
List<XFile?> multiImage = []; // 갤러리에서 여러장의 사진을 선택해서 저장할 변수
List<XFile?> images = []; // 가져온 사진들을 보여주기 위한 변수

class _writediaryState extends State<writediary> {
  ApiManager apiManager = ApiManager().getApiManager();

  //late String title;
  late String content = _contentEditController.text;
  late String sendEmotion = widget.emotion;
  DateTime dateTime = DateTime.now();
  late String created_at = dateTime.toIso8601String();
  bool _isChecked = false;
  bool _isCheckedShare = false;

  Future<void> GetExample(String endpoint) async {
    try {
      final response = await apiManager.Get(endpoint); // 실제 API 엔드포인트로 대체

      // 요청 응답 받기
      final value = response['key']; // 키를 통해 value를 받아오기
      print('Data: $value');

      //title = response['title'];
    } catch (e) {
      print('Error: $e');
    }
  }

  // onpress():
  //      PostExample("/api/message");
  //
  // 다른버튼 onperss():
  //       PostExample("api/title");

  Future<void> PostExample(String endpoint) async {
    ApiManager apiManager = ApiManager().getApiManager();

    try {
      final postData = {
        'content': content,
        'emotion': sendEmotion,
        'is_share': _isCheckedShare,
        'is_comm': _isChecked,
      };

      print(postData);

      await apiManager.post(endpoint, postData); // 실제 API 엔드포인트로 대체
    } catch (e) {
      print('Error: $e');
    }
  }

  final _contentEditController = TextEditingController();

  //녹음에 필요한 것들
  final recorder = sound.FlutterSoundRecorder();
  bool isRecorderReady = false;

  //재생에 필요한 것들
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    setAudio();

    initRecorder();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == (PlayerState.playing);
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.loop);

    String url = ' ';
    audioPlayer.setSourceUrl(url);
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    audioPlayer.dispose();

    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }

    await recorder.openRecorder();
    isRecorderReady = true;

    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  Future record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: 'audio');
  }

  Future stop() async {
    if (!isRecorderReady) return;

    final path = await recorder.stopRecorder();
    final audioFile = File(path!);

    print('Recorded audio: $audioFile');
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inMinutes.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Color(0xFFF8F5EB),
        title: Container(
          //decoration: BoxDecoration(color: Colors.amber),
          child: (() {
            switch (widget.emotion) {
              case 'smile':
                return Image.asset(
                  'images/emotion/1.gif',
                  height: 45,
                  width: 45,
                );
              case 'flutter':
                return Image.asset(
                  'images/emotion/2.gif',
                  height: 45,
                  width: 45,
                );
              case 'angry':
                return Image.asset(
                  'images/emotion/3.gif',
                  height: 45,
                  width: 45,
                );
              case 'annoying':
                return Image.asset(
                  'images/emotion/4.gif',
                  height: 45,
                  width: 45,
                );
              case 'tired':
                return Image.asset(
                  'images/emotion/5.gif',
                  height: 45,
                  width: 45,
                );
              case 'sad':
                return Image.asset(
                  'images/emotion/6.gif',
                  height: 45,
                  width: 45,
                );
              case 'calmness':
                return Image.asset(
                  'images/emotion/7.gif',
                  height: 45,
                  width: 45,
                );
            }
          })(),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyApp()));
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF968C83),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              print("PostExample 실행");
              PostExample("/api/diaries/create");
            },
            icon: Image.asset(
              "images/send/upload.png",
              width: 30,
              height: 30,
              color: Color(0xFF968C83),
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF8F5EB),
        ),
        child: Column(
          children: [
            Container(
                width: sizeX * 0.88,
                height: sizeY * 0.75,
                margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 120, 20),
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          color: Color(0xFF7D5A50),
                          fontSize: 20,
                          fontFamily: 'soojin',
                        ),
                      ), //날짜 변경 해야함
                    ), // 날짜
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                                margin: EdgeInsets.all(10),
                                //color: Colors.amber,
                                width: 200, height: 150,
                                child: GridView.builder(
                                    padding: EdgeInsets.all(0),
                                    shrinkWrap: true,
                                    itemCount: images.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 1 / 1,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                    ),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            image: DecorationImage(
                                               fit: BoxFit.cover,
                                                image: FileImage(
                                                  File(images[index]!.path ),
                                                ))),
                                      );
                                    })),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.transparent,
                                    child: IconButton(
                                      icon: Icon(
                                        isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                      ),
                                      iconSize: 20,
                                      color: Color(0xFF968C83),
                                      onPressed: () async {
                                        if (isPlaying) {
                                          await audioPlayer.pause();
                                        } else {
                                          await audioPlayer.resume();
                                        }
                                      },
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Slider(
                                        min: 0,
                                        max: duration.inSeconds.toDouble(),
                                        value: position.inSeconds.toDouble(),
                                        onChanged: (value) async {
                                          final position =
                                              Duration(seconds: value.toInt());
                                          await audioPlayer.seek(position);

                                          await audioPlayer.resume();
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(formatTime(position)),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text(formatTime(
                                                duration - position)),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ]), //음성
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: TextField(
                                style: TextStyle(fontFamily: 'soojin'),
                                controller: _contentEditController,
                                maxLines: 10,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                ))),
                              ),
                            )
                          ],
                        ),
                      ),
                    ), //일기 내용
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            child: IconButton(
                              onPressed: () async {
                                multiImage = await picker.pickMultiImage();
                                setState(() {
                                  images.addAll(multiImage);
                                });
                              },
                              icon: Image.asset(
                                "images/main/gallery.png",
                                width: 35,
                                height: 35,
                                color: Color(0xFF968C83),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              /*StreamBuilder<sound.RecordingDisposition>(
                                stream: recorder.onProgress,
                                builder: (context,snapshot) {
                                  final duration = snapshot.hasData
                                      ? snapshot.data!.duration
                                      : Duration.zero;

                                  String twoDigits(int n) => n.toString().padLeft(10);
                                  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
                                  final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

                                  return Text('$twoDigitMinutes:$twoDigitSeconds',style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),);
                                },
                            ),
                            const SizedBox(height: 5),
                              SizedBox(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.red,
                                  minimumSize: Size(20, 30)
                                ),
                                child: Icon(recorder.isRecording ? Icons.stop : Icons.mic,size: 30,color: Colors.black,),
                                onPressed: ()async{
                                  if(recorder.isRecording){
                                    await stop();
                                  }else{
                                    await record();
                                  }

                                  setState(() {

                                  });
                                },
                              ),
                            ),*/
                              SizedBox(
                                child: IconButton(
                                  onPressed: () async {
                                    if (recorder.isRecording) {
                                      await stop();
                                    } else {
                                      await record();
                                    }
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    recorder.isRecording
                                        ? Icons.stop
                                        : Icons.mic,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ), // 사진 추가, 음성 녹음
                  ],
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  width: sizeX * 0.4,
                  height: sizeY * 0.07,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        child: Text(
                          "댓글 허용",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      CupertinoSwitch(
                        value: _isChecked,
                        activeColor: CupertinoColors.activeGreen,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ), //댓글 허용 onoff
                Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  width: sizeX * 0.4,
                  height: sizeY * 0.07,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: Text(
                          "오늘 일기 공유",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      CupertinoSwitch(
                        value: _isCheckedShare,
                        activeColor: CupertinoColors.activeGreen,
                        onChanged: (bool? value) {
                          setState(() {
                            _isCheckedShare = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ), //오늘 일기 공유 onoff
              ],
            ),
          ],
        ),
      ),
    );
  }
}
