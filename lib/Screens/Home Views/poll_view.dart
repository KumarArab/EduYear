import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PollSection extends StatefulWidget {
  @override
  _PollSectionState createState() => _PollSectionState();
}

class _PollSectionState extends State<PollSection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: StreamBuilder(
        stream: Firestore.instance.collection("Poll-Posts").snapshots(),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Text('PLease Wait')
              : ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot products = snapshot.data
                        .documents[snapshot.data.documents.length - 1 - index];
                    // Map<String, dynamic> imagesMap = new Map<String, dynamic>();
                    // imagesMap = products["images"];
                    // List<String> mapurls = [];
                    // imagesMap != null
                    //     ? imagesMap.forEach((key, value) {
                    //         mapurls.add(value);
                    //       })
                    //     : {};

                    // if (mapurls.length == 1) {
                    return (PollCard(
                      question: products["question"],
                      voteForA: products["voteForA"],
                      voteForB: products["voteForB"],
                      optionA: products["optionA"],
                      optionB: products["optionB"],
                      userId: products["user_id"],
                      postNo: products["postNo"],
                      username: products["name"],
                    ));
                    //}

                    // return Container(
                    //     child: ImageCard(imageUrl: products["url"]));
                  },
                );
        },
      ),
    );
  }
}

class PollCard extends StatefulWidget {
  final String question,
      voteForB,
      voteForA,
      optionA,
      optionB,
      userId,
      postNo,
      username;
  PollCard({
    this.question,
    this.voteForB,
    this.voteForA,
    this.optionA,
    this.optionB,
    this.userId,
    this.postNo,
    this.username,
  });
  @override
  _PollCardState createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  double calculateWidth() {
    int voteA = int.tryParse(widget.voteForA);
    int voteB = int.tryParse(widget.voteForB);
    double width = voteA / (voteA + voteB);
    return width;
  }

  Future<void> updateOptionA(String id, String postNo) async {
    int voteA = int.tryParse(widget.voteForA);
    String updatedVote = (voteA + 1).toString();

    DocumentReference documentReference =
        Firestore.instance.collection("Poll-Posts").document("$id-$postNo");
    documentReference.updateData({"voteForA": updatedVote});
  }

  Future<void> updateOptionB(String id, String postNo) async {
    int voteB = int.tryParse(widget.voteForB);
    String updatedVote = (voteB + 1).toString();

    DocumentReference documentReference =
        Firestore.instance.collection("Poll-Posts").document("$id-$postNo");
    documentReference.updateData({"voteForB": updatedVote});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(3, 3),
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.username,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            padding: EdgeInsets.only(bottom: 5),
          ),
          Container(
            child: Center(
              child: Text(widget.question),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.optionA),
                    Text(widget.optionB),
                  ],
                ),
                Container(
                  height: 20,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.red,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: calculateWidth(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.green,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: RaisedButton(
                      onPressed: () {
                        // setState(() {
                        //   voteForA = 1;
                        //   voteForB = 0;

                        //   isAnswered = true;
                        //   userChoice = option1;
                        // });

                        updateOptionA(widget.userId, widget.postNo);
                      },
                      child: Text(widget.optionA),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: RaisedButton(
                      onPressed: () {
                        // voteForB = 1;
                        // voteForA = 0;

                        // setState(() {
                        //   isAnswered = true;
                        //   userChoice = option2;
                        // });
                        updateOptionB(widget.userId, widget.postNo);
                      },
                      child: Text(widget.optionB),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
