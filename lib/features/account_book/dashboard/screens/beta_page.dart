import 'package:flutter/material.dart';

class BetaPage extends StatefulWidget {
  const BetaPage({super.key});

  @override
  State<BetaPage> createState() => _betaState();
}

class _betaState extends State<BetaPage> {
  final List<Map<String, dynamic>> _data = []; // 데이터를 저장할 리스트

  void _addData() {
    setState(() {
      _data.add({
        "날짜": "${_data.length + 1}",
        "내역": "내역 ${_data.length + 1}",
        "금액": "${_data.length * 1000}",
        "카드": "${_data.length + 1}",
        "현금": "${_data.length + 1}",
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // 반응형 너비 계산
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(255, 120, 172, 196),
            titleSpacing: 0,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    Spacer(),

                    Text(
                      "이번달의 목표는?",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: screenWidth * 0.06, // 반응형 폰트 크기
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),

                    Icon(Icons.edit, size: 16),
                    Spacer(),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("2025년"),
                  const SizedBox(width: 10),
                  Text("8월"),
                ],
              ),
              // 고정된 테이블 헤더
              Table(
                border: TableBorder(
                  top: BorderSide(color: Colors.black, width: 1),
                  bottom: BorderSide(color: Colors.black, width: 1),
                  verticalInside: BorderSide(color: Colors.black, width: 1),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1), // 날짜
                  1: FlexColumnWidth(3), // 내역
                  2: FlexColumnWidth(3), // 지출
                  3: FlexColumnWidth(1), // 카드
                  4: FlexColumnWidth(1), // 현금
                },
                children: [
                  TableRow(
                    children: [
                      _buildHeaderCell("날짜"),
                      _buildHeaderCell("내역"),
                      _buildHeaderCell("금액"),
                      _buildHeaderCell("카드"),
                      _buildHeaderCell("현금"),
                    ],
                  ),
                ],
              ),
              // 고정된 빈 테이블
              Expanded(
                child: ListView.builder(
                  itemCount: _data.length + 15, // 고정된 빈 행 + 데이터 행
                  itemBuilder: (context, index) {
                    if (index < _data.length) {
                      // 데이터가 있는 경우
                      final item = _data[index];
                      return Table(
                        border: TableBorder(
                          bottom: BorderSide(color: Colors.black, width: 1),
                          verticalInside: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(1), // 날짜
                          1: FlexColumnWidth(3), // 내역
                          2: FlexColumnWidth(3), // 지출
                          3: FlexColumnWidth(1), // 카드
                          4: FlexColumnWidth(1), // 현금
                        },
                        children: [
                          TableRow(
                            children: [
                              _buildCell(item["날짜"]),
                              _buildCell(item["내역"]),
                              _buildCell(item["금액"]),
                              _buildCell(item["카드"]),
                              _buildCell(item["현금"]),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // 데이터가 없는 경우 빈 행 렌더링
                      return Table(
                        border: TableBorder(
                          bottom: BorderSide(color: Colors.black, width: 1),
                          verticalInside: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(1), // 날짜
                          1: FlexColumnWidth(3), // 내역
                          2: FlexColumnWidth(3), // 지출
                          3: FlexColumnWidth(1), // 카드
                          4: FlexColumnWidth(1), // 현금
                        },
                        children: [
                          TableRow(
                            children: [
                              _buildCell(""),
                              _buildCell(""),
                              _buildCell(""),
                              _buildCell(""),
                              _buildCell(""),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              // 결과
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildTotal(
                      text: "현금",
                      topBorder: 1,
                      rightBorder: 1,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildTotal(rightBorder: 1, topBorder: 1),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildTotal(
                      text: "수익",
                      rightBorder: 1,
                      topBorder: 1,
                    ),
                  ),
                  Expanded(flex: 2, child: _buildTotal(topBorder: 1)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildTotal(text: "합계", rightBorder: 1),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildTotal(text: "100000000", rightBorder: 1),
                  ),
                  Expanded(flex: 3, child: Container()),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addData,
          backgroundColor: Colors.blue,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1, // 텍스트 줄 제한
        overflow: TextOverflow.ellipsis, // 줄바꿈 방지
      ),
    );
  }
}

class _buildTotal extends StatelessWidget {
  final String? text;
  final int topBorder;
  final int rightBorder;
  const _buildTotal({
    super.key,
    this.text,
    this.topBorder = 0,
    this.rightBorder = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: topBorder == 0
              ? BorderSide.none
              : BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: Colors.black, width: 1),
          left: BorderSide.none,
          right: rightBorder == 0
              ? BorderSide.none
              : BorderSide(color: Colors.black, width: 1),
        ),
      ),
      alignment: Alignment.center, // 텍스트 가운데 정렬
      child: Text(
        text ?? "",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14), // 반응형 폰트 크기
      ),
    );
  }
}
