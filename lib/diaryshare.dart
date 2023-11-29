import 'dart:core';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:capston1/network/api_manager.dart';
import 'comment.dart';
import 'message_write.dart';
import 'package:audioplayers/audioplayers.dart';
import 'models/Comment.dart';
import 'models/Diary.dart';

//맨 위 상단 감정 7개
final List<String> imagePaths = [
  'images/emotion/calmness.gif',
  'images/emotion/smile.gif',
  'images/emotion/flutter.gif',
  'images/emotion/angry.png',
  'images/emotion/annoying.gif',
  'images/emotion/tired.gif',
  'images/emotion/sad.gif',
];

String formattedDate = DateFormat('yyyy년 MM월 dd일').format(DateTime.now());
String selectedImageEmotion = ' '; // 기본으로 'images/emotion/calmness.gif'를 선택

class diaryshare extends StatefulWidget {
  diaryshare({Key? key}) : super(key: key);

  @override
  State<diaryshare> createState() => _diaryshareState();
}

List<Diary> diaries = [];

class _diaryshareState extends State<diaryshare> {
  ApiManager apiManager = ApiManager().getApiManager();

  List<Diary> selectedEmotionDiaries = [];
  int favoriteCounts = 0;
  String selectedValue = '최신순';

  @override
  void initState() {
    super.initState();
    fetchDataFromServer();
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
    return Container(
      color: Color(0xFFF8F5EB),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드롭박스
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<String>(
                  value: selectedValue,
                  // 현재 선택된 값
                  items: <String>['공감순', '최신순'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedValue = value!; // 선택된 값 업데이트
                    });
                  },
                  underline: Container(
                    height: 2,
                    color: Colors.brown,
                  ),
                  dropdownColor: Color(0xFFF8F5EB),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.brown),
                  style: TextStyle(color: Colors.black, fontFamily: 'soojin'),
                ),
                SizedBox(width: 25),
              ],
            ),
          ),
          //날짜
          Container(
            //   margin: EdgeInsets.fromLTRB(0, 20, 120, 20),
            child: Text(
              formattedDate,
              style: TextStyle(
                color: Color(0xFF7D5A50),
                fontSize: 17,
                fontWeight: FontWeight.w900,
                fontFamily: 'soojin',
              ),
            ), //날짜
          ),
          //감정 아이콘
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: ClampingScrollPhysics(),
            child: Row(
              children: imagePaths.asMap().entries.map((entry) {
                String imagePath = entry.value;
                String emotion = "";
                switch (imagePath) {
                  case 'images/emotion/angry.png':
                    emotion = "angry";
                    break;
                  case "images/emotion/flutter.gif":
                    emotion = 'flutter';
                    break;
                  case "images/emotion/smile.gif":
                    emotion = 'smile';
                    break;
                  case "images/emotion/annoying.gif":
                    emotion = 'annoying';
                    break;
                  case "images/emotion/sad.gif":
                    emotion = 'sad';
                    break;
                  case "images/emotion/calmness.gif":
                    emotion = 'calmness';
                    break;
                  case "images/emotion/tired.gif":
                    emotion = 'tired';
                    break;
                  default:
                    emotion = 'flutter';
                    break;
                }
                // 해당 이미지에 대한 일기 내용을 찾기
                List<Diary> diariesWithSelectedEmotion =
                    diaries.where((diary) => diary.emotion == emotion).toList();

                return Padding(
                  padding: EdgeInsets.all(3),
                  child: IconButton(
                    icon: Image.asset(
                      imagePath,
                      width: 50,
                      height: 50,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedImageEmotion = emotion;
                        selectedEmotionDiaries = diariesWithSelectedEmotion;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(10),
              itemCount: diaries.length,
              itemBuilder: (BuildContext context, int index) {
                if (selectedImageEmotion == diaries[index].emotion) {
                  return SizedBox(
                    child: (() {
                      if (diaries[index].imagePath.isNotEmpty &&
                          diaries[index].voice == "") {
                        return customWidget1(
                          simagePath: diaries[index].emotion,
                          sdiaryImage: diaries[index].imagePath,
                          scomment: diaries[index].content,
                          sfavoritColor: diaries[index].favoriteColor,
                          sfavoritCount: diaries[index].favoriteCount,
                          otherUserId: diaries[index].userId,
                        );
                      } else if (diaries[index].imagePath.isEmpty &&
                          diaries[index].voice == "") {
                        return customWidget2(
                          scomment: diaries[index].content,
                          sfavoritColor: diaries[index].favoriteColor,
                          sfavoritCount: diaries[index].favoriteCount,
                          simagePath: diaries[index].emotion,
                          otherUserId: diaries[index].userId,
                          diaryId: diaries[index].diaryId,
                          diaryComment: diaries[index].diaryComment,
                        );
                      } else if (diaries[index].imagePath.isEmpty &&
                          diaries[index].voice != "") {
                        return customwidget3(
                          scomment: diaries[index].content,
                          sfavoritColor: diaries[index].favoriteColor,
                          sfavoritCount: diaries[index].favoriteCount,
                          simagePath: diaries[index].emotion,
                          svoice: diaries[index].voice,
                          otherUserId: diaries[index].userId,
                        );
                      } else if (diaries[index].imagePath.isNotEmpty &&
                          diaries[index].voice != "") {
                        return customwidget4(
                          sdiaryImage: diaries[index].imagePath,
                          scomment: diaries[index].content,
                          sfavoritColor: diaries[index].favoriteColor,
                          sfavoritCount: diaries[index].favoriteCount,
                          simagePath: diaries[index].emotion,
                          svoice: diaries[index].voice,
                          otherUserId: diaries[index].userId,
                        );
                      }
                    })(),
                  );
                } else {
                  // 선택된 이미지에 해당하는 일기가 없을 경우 빈 컨테이너 반환
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 일기 버전 1 - 텍스트 + 사진
class customWidget1 extends StatefulWidget {
  final String simagePath;
  final List<String> sdiaryImage;
  final String scomment;
  final int sfavoritCount;
  final bool sfavoritColor;
  final int otherUserId;

  const customWidget1({
    super.key,
    required this.simagePath,
    required this.sdiaryImage,
    required this.scomment,
    required this.sfavoritColor,
    required this.sfavoritCount,
    required this.otherUserId,
  });

  @override
  State<customWidget1> createState() =>
      _customWidget1State(otherUserId, sfavoritCount);
}

class _customWidget1State extends State<customWidget1> {
  //late int sfavoritCount; // 추가된 부분
  late bool sfavoritColor; // 추가된 부분
  String imagePath = "";
  int otherUserId = 36;
  int DiaryId = 1;
  int favoriteCounts = 0;
  final List<Comment> comments = []; // 댓글을 관리하는 리스트

  ApiManager apiManager = ApiManager().getApiManager();

  _customWidget1State(int otherUserId, int favoriteCounts) {
    this.otherUserId = otherUserId;
    this.favoriteCounts = favoriteCounts;
  }

  void initState() {
    super.initState();
    favoriteCounts = widget.sfavoritCount;
    sfavoritColor = widget.sfavoritColor;
    switch (widget.simagePath) {
      case "angry":
        imagePath = 'images/emotion/angry.png';
        break;
      case "flutter":
        imagePath = 'images/emotion/flutter.gif';
        break;
      case "smile":
        imagePath = 'images/emotion/smile.gif';
        break;
      case "annoying":
        imagePath = 'images/emotion/annoying.gif';
        break;
      case "sad":
        imagePath = 'images/emotion/sad.gif';
        break;
      case "calmness":
        imagePath = 'images/emotion/calmness.gif';
        break;
      case "tired":
        imagePath = 'images/emotion/tired.gif';
        break;
      default:
        imagePath = 'images/emotion/flutter.gif';
        break;
    }
  }

  void plusDialog(BuildContext context) {
    final sizeY = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            height: sizeY * 0.8,
            color: Color(0xFF737373),
            //child: comment(postId:), // 수정이 필요한 부분
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 380,
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                Container(
                  width: 380,
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 35,
                          height: 35,
                          margin: EdgeInsets.only(left: 50),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(imagePath),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      )),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  message_write(otherUserId: otherUserId),
                            ),
                          );
                        },
                        icon: Image.asset(
                          'images/send/real_send.png',
                          height: 50, // 이미지 높이 조절
                          width: 30, // 이미지 너비 조절
                        ),
                      ),
                    ],
                  ),
                ),
                //이미지
                SingleChildScrollView(
                  child: Container(
                      width: 200,
                      height: 150, // 이미지 높이 조절
                      child: Container(
                        child: PageView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.sdiaryImage.length > 3
                              ? 3
                              : widget.sdiaryImage.length, // 최대 3장까지만 허용
                          itemBuilder: (context, index) {
                            return Container(
                              child: Center(
                                child: Image.asset(widget.sdiaryImage[index]),
                              ),
                            );
                          },
                        ),
                      )),
                ),
                //텍스트
                Container(
                    width: 380,
                    padding: const EdgeInsets.fromLTRB(35, 20, 35, 10),
                    color: Colors.white54,
                    child: Column(
                      children: [
                        Text(
                          widget.scomment,
                          style: TextStyle(fontSize: 15, fontFamily: 'soojin'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
              ],
            ),
          ),
          //좋아요,댓글
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          // 좋아요 누를 때 색 변경 및 count 증가
                          if (sfavoritColor) {
                            favoriteCounts--;
                          } else {
                            favoriteCounts++;
                          }
                          sfavoritColor = !sfavoritColor;
                        });
                      },
                      onLongPress: () {},
                      child: Icon(
                        Icons.favorite,
                        color: sfavoritColor ? Colors.red : Colors.grey,
                      ),
                    ),
                    Text(
                      '$favoriteCounts',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),

              //댓글
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        plusDialog(context);
                      },
                      child: Icon(Icons.chat_outlined, color: Colors.grey),
                    ),
                    //댓글 숫자
                    Text(
                      '0',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}

//글만 있는 거
class customWidget2 extends StatefulWidget {
  final String simagePath;
  final String scomment;
  final int sfavoritCount;
  final bool sfavoritColor;
  final int otherUserId;
  final int diaryId;
  final int diaryComment;

  const customWidget2({
    super.key,
    required this.simagePath,
    required this.scomment,
    required this.sfavoritColor,
    required this.sfavoritCount,
    required this.otherUserId,
    required this.diaryId,
    required this.diaryComment,
  });

  @override
  State<customWidget2> createState() =>
      _customWidget2State(otherUserId, diaryId, sfavoritCount, diaryComment);
}

class _customWidget2State extends State<customWidget2> {
  late bool sfavoritColor; //false로 초기화
  final List<Comment> comments = []; // 댓글을 관리하는 리스트
  int otherUserId = 36;
  String imagePath = "";
  int diaryId = 0;
  TextEditingController _commentController = TextEditingController();
  int _commentCount = 0;
  int favoriteCounts = 0;
  int diaryComment = 0;

  ApiManager apiManager = ApiManager().getApiManager();

  _customWidget2State(
      int otherUserId, int diaryId, int sfavoritCount, int diaryComment) {
    this.otherUserId = otherUserId;
    this.diaryId = diaryId;
    this.favoriteCounts = favoriteCounts;
    this.diaryComment = diaryComment;
  }

  void plusDialog(BuildContext context) {
    final sizeY = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            height: sizeY * 0.8,
            color: Color(0xFF737373),
            child: comment(postId: diaryComment),
          ),
        );
      },
    );
  }

  void initState() {
    super.initState();
    favoriteCounts = widget.sfavoritCount; // 초기화
    sfavoritColor = widget.sfavoritColor;
    switch (widget.simagePath) {
      case "angry":
        imagePath = 'images/emotion/angry.png';
        break;
      case "flutter":
        imagePath = 'images/emotion/flutter.gif';
        break;
      case "smile":
        imagePath = 'images/emotion/smile.gif';
        break;
      case "annoying":
        imagePath = 'images/emotion/annoying.gif';
        break;
      case "sad":
        imagePath = 'images/emotion/sad.gif';
        break;
      case "calmness":
        imagePath = 'images/emotion/calmness.gif';
        break;
      case "tired":
        imagePath = 'images/emotion/tired.gif';
        break;
      default:
        imagePath = 'images/emotion/flutter.gif';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 380,
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                Container(
                  width: 380,
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 35,
                          height: 35,
                          margin: EdgeInsets.only(left: 50),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(imagePath),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      )),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  message_write(otherUserId: otherUserId),
                            ),
                          );
                        },
                        icon: Image.asset(
                          'images/send/real_send.png',
                          height: 50, // 이미지 높이 조절
                          width: 30, // 이미지 너비 조절
                        ),
                      ),
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
                          style: TextStyle(fontSize: 15, fontFamily: 'soojin'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
              ],
            ),
          ),
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        apiManager.putFavoriteCount(diaryId);
                        try {
                          setState(() {
                            if (sfavoritColor) {
                              favoriteCounts--;
                            } else {
                              favoriteCounts++;
                            }
                            sfavoritColor = !sfavoritColor;
                          });
                        } catch (error) {
                          print('Error updating favorite count: $error');
                        }
                      },
                      child: Icon(
                        Icons.favorite,
                        color: sfavoritColor ? Colors.red : Colors.grey,
                      ),
                    ),
                    Text(
                      '$favoriteCounts',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              //댓글
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        plusDialog(context);
                      },
                      child: Icon(Icons.chat_outlined, color: Colors.grey),
                    ),
                    //댓글 숫자
                    Text(
                      '6', //
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}

// 일기 버전 3 - 텍스트 + 음성
class customwidget3 extends StatefulWidget {
  final String simagePath;
  final String scomment;
  final int sfavoritCount;
  final bool sfavoritColor;
  final String svoice;
  final int otherUserId;

  const customwidget3({
    super.key,
    required this.simagePath,
    required this.scomment,
    required this.sfavoritColor,
    required this.sfavoritCount,
    required this.svoice,
    required this.otherUserId,
  });

  @override
  State<customwidget3> createState() => _customwidget3State(otherUserId);
}

class _customwidget3State extends State<customwidget3> {
  final List<Comment> comments = []; // 댓글을 관리하는 리스트

  TextEditingController _commentController = TextEditingController();

  late int sfavoritCount; // 추가된 부분
  late bool sfavoritColor; // 추가된 부분
  int otherUserId = 36;
  int _commentCount = 1;

  _customwidget3State(int otherUserId) {
    this.otherUserId = otherUserId;
  }

  void plusDialog(BuildContext context) {
    final sizeY = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            height: sizeY * 0.8,
            color: Color(0xFF737373),
            //child: comment(),
          ),
        );
      },
    );
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
    setAudio();
    sfavoritCount = widget.sfavoritCount; // 초기화
    sfavoritColor = widget.sfavoritColor; // 초기화
    switch (widget.simagePath) {
      case "angry":
        imagePath = 'images/emotion/angry.png';
        break;
      case "flutter":
        imagePath = 'images/emotion/flutter.gif';
        break;
      case "smile":
        imagePath = 'images/emotion/smile.gif';
        break;
      case "annoying":
        imagePath = 'images/emotion/annoying.gif';
        break;
      case "sad":
        imagePath = 'images/emotion/sad.gif';
        break;
      case "calmness":
        imagePath = 'images/emotion/calmness.gif';
        break;
      case "tired":
        imagePath = 'images/emotion/tired.gif';
        break;
      default:
        imagePath = 'images/emotion/flutter.gif';
        break;
    }

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
    String url = ' ';
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.setSourceUrl(url);
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 380,
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                Container(
                  width: 380,
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 35,
                          height: 35,
                          margin: EdgeInsets.only(left: 50),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(imagePath),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      )),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  message_write(otherUserId: otherUserId),
                            ),
                          );
                        },
                        icon: Image.asset(
                          'images/send/real_send.png',
                          height: 50, // 이미지 높이 조절
                          width: 30, // 이미지 너비 조절
                        ),
                      ),
                    ],
                  ),
                ),
                //녹음
                Container(
                  padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: Column(
                    children: [
                      Slider(
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds.toDouble(),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await audioPlayer.seek(position);
                          await audioPlayer.resume();
                        },
                        activeColor: Color(0xFFF8F5EB),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatTime(position), // 진행중인 시간
                              style: TextStyle(
                                  color:
                                      Colors.brown), // Set text color to black
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.transparent,
                              child: IconButton(
                                padding: EdgeInsets.only(bottom: 50),
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.brown,
                                ),
                                iconSize: 25,
                                onPressed: () async {
                                  if (isPlaying) {
                                    await audioPlayer.pause();
                                  } else {
                                    await audioPlayer.resume();
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              formatTime(duration), //총 시간
                              style: TextStyle(
                                color: Colors.brown,
                              ), // Set text color to black
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                //텍스트
                Container(
                    width: 380,
                    padding: const EdgeInsets.fromLTRB(35, 20, 35, 10),
                    color: Colors.white54,
                    child: Column(
                      children: [
                        Text(
                          widget.scomment,
                          style: TextStyle(fontSize: 15, fontFamily: 'soojin'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
              ],
            ),
          ),
          //좋아요,댓글
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (sfavoritColor) {
                            sfavoritCount--;
                          } else {
                            sfavoritCount++;
                          }
                          sfavoritColor = !sfavoritColor;
                        });
                      },
                      onLongPress: () {},
                      child: Icon(
                        Icons.favorite,
                        color: sfavoritColor ? Colors.red : Colors.grey,
                      ),
                    ),
                    Text(
                      '$sfavoritCount',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              //댓글
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        plusDialog(context);
                      },
                      child: Icon(Icons.chat_outlined, color: Colors.grey),
                    ),
                    //댓글 숫자
                    Text(
                      '6', //
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}

// 일기 버전4 - 텍스트 + 음성 + 사진
class customwidget4 extends StatefulWidget {
  final List<String> sdiaryImage; // 다이어리 안에 이미지
  final String simagePath; // 감정 이모지 사진
  final String scomment; // 일기 내용
  final int sfavoritCount; // 좋아요 수
  final bool sfavoritColor; // 좋아요 색 변하는 거
  final String svoice; // 녹음 기능
  final int otherUserId;

  const customwidget4({
    super.key,
    required this.sdiaryImage,
    required this.simagePath,
    required this.scomment,
    required this.sfavoritColor,
    required this.sfavoritCount,
    required this.svoice,
    required this.otherUserId,
  });

  @override
  State<customwidget4> createState() => _customwidget4State(otherUserId);
}

class _customwidget4State extends State<customwidget4> {
  late int sfavoritCount;
  late bool sfavoritColor; // 추가된 부분
  int otherUserId = 36;
  final List<Comment> comments = []; // 댓글을 관리하는 리스트

  TextEditingController _commentController = TextEditingController();

  _customwidget4State(int otherUserId) {
    this.otherUserId = otherUserId;
  }

  void plusDialog(BuildContext context) {
    final sizeY = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            height: sizeY * 0.8,
            color: Color(0xFF737373),
            //   child: comment(),
          ),
        );
      },
    );
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
    setAudio();
    sfavoritCount = widget.sfavoritCount; // 초기화
    sfavoritColor = widget.sfavoritColor; // 초기화

    switch (widget.simagePath) {
      case "angry":
        imagePath = 'images/emotion/angry.png';
        break;
      case "flutter":
        imagePath = 'images/emotion/flutter.gif';
        break;
      case "smile":
        imagePath = 'images/emotion/smile.gif';
        break;
      case "annoying":
        imagePath = 'images/emotion/annoying.gif';
        break;
      case "sad":
        imagePath = 'images/emotion/sad.gif';
        break;
      case "calmness":
        imagePath = 'images/emotion/calmness.gif';
        break;
      case "tired":
        imagePath = 'images/emotion/tired.gif';
        break;
      default:
        imagePath = 'images/emotion/flutter.gif';
        break;
    }

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
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 380,
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                Container(
                  width: 380,
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 35,
                          height: 35,
                          margin: EdgeInsets.only(left: 50),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(imagePath),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      )),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  message_write(otherUserId: otherUserId),
                            ),
                          );
                        },
                        icon: Image.asset(
                          'images/send/real_send.png',
                          height: 50, // 이미지 높이 조절
                          width: 30, // 이미지 너비 조절
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                      width: 200,
                      height: 150, // 이미지 높이 조절
                      child: Container(
                        child: PageView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.sdiaryImage.length > 3
                              ? 3
                              : widget.sdiaryImage.length, // 최대 3장까지만 허용
                          itemBuilder: (context, index) {
                            return Container(
                              child: Center(
                                child: Image.asset(widget.sdiaryImage[index]),
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
                      Slider(
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds.toDouble(),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await audioPlayer.seek(position);
                          await audioPlayer.resume();
                        },
                        activeColor: Color(0xFFF8F5EB),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatTime(position), // 진행중인 시간
                              style: TextStyle(
                                  color:
                                      Colors.brown), // Set text color to black
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.transparent,
                              child: IconButton(
                                padding: EdgeInsets.only(bottom: 50),
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.brown,
                                ),
                                iconSize: 25,
                                onPressed: () async {
                                  if (isPlaying) {
                                    await audioPlayer.pause();
                                  } else {
                                    await audioPlayer.resume();
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              formatTime(duration), //총 시간
                              style: TextStyle(
                                color: Colors.brown,
                              ), // Set text color to black
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                //텍스트
                Container(
                    width: 380,
                    padding: const EdgeInsets.fromLTRB(35, 20, 35, 10),
                    color: Colors.white54,
                    child: Column(
                      children: [
                        Text(
                          widget.scomment,
                          style: TextStyle(fontSize: 15, fontFamily: 'soojin'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
              ],
            ),
          ),
          //좋아요,댓글
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          // 좋아요 누를 때 색 변경 및 count 증가
                          if (sfavoritColor) {
                            sfavoritCount--;
                          } else {
                            sfavoritCount++;
                          }
                          sfavoritColor = !sfavoritColor;
                        });
                      },
                      onLongPress: () {},
                      child: Icon(
                        Icons.favorite,
                        color: sfavoritColor ? Colors.red : Colors.grey,
                      ),
                    ),
                    Text(
                      '$sfavoritCount',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              //댓글
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        plusDialog(context);
                      },
                      child: Icon(Icons.chat_outlined, color: Colors.grey),
                    ),
                    //댓글 숫자
                    Text(
                      '6', //
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
